#!/usr/bin/env bash
# Self-test for the textual guards' shared lexer (scripts/lean-code-scan.awk).
# Each case is a Lean snippet plus the expected number of violating lines per mode.
# Run after every edit of the lexer:  bash scripts/test-guards.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
fail=0; n=0

# case <name> <expected-sorry-hits> <expected-axiom-hits> <<'EOF' ... EOF
case_() {
  local name="$1" want_s="$2" want_a="$3" f="$tmp/$1.lean" got_s got_a
  cat > "$f"
  n=$((n + 1))
  got_s="$(awk -v mode=sorry -f scripts/lean-code-scan.awk "$f" | wc -l)"
  got_a="$(awk -v mode=axiom -f scripts/lean-code-scan.awk "$f" | wc -l)"
  if [ "$got_s" -ne "$want_s" ] || [ "$got_a" -ne "$want_a" ]; then
    echo "FAIL [$name]: sorry want $want_s got $got_s; axiom want $want_a got $got_a"; fail=1
  fi
}

case_ plain_sorry 1 0 <<'EOF'
theorem t : True := by sorry
EOF
case_ marked_sorry 0 0 <<'EOF'
theorem t : True := by sorry -- ALLOW_SORRY: #12 statement contract
EOF
case_ sorry_in_comments 0 0 <<'EOF'
-- sorry in a line comment
/- sorry in a block comment
   /- nested sorry -/ still comment -/
/-- docstring: this lemma is sorry-free -/
theorem t : True := trivial
EOF
case_ sorry_in_string 0 0 <<'EOF'
def msg : String := "sorry, admit nothing"
EOF
case_ string_with_comment_opener 1 1 <<'EOF'
def marker : String := "/-"
theorem hidden : False := sorry
axiom bad : False
EOF
case_ escaped_quote_in_string 1 0 <<'EOF'
def s : String := "say \"/-\" here"
theorem t : True := by sorry
EOF
case_ multiline_string 1 0 <<'EOF'
def s : String := "line one /-
line two -- sorry inside string
end"
theorem t : True := by admit
EOF
case_ char_literal_quote 1 0 <<'EOF'
def c : Char := '"'
theorem t : True := by sorry
EOF
case_ char_literal_escaped 1 0 <<'EOF'
def c : Char := '\''
def d : Char := '\n'
theorem t : True := by sorry
EOF
case_ primed_identifiers 1 0 <<'EOF'
theorem h' (h'' : True) : True := by sorry
EOF
case_ axiom_forms 0 4 <<'EOF'
axiom a : True
@[simp] private axiom b : True
noncomputable opaque c : Nat
unsafe def d : Nat := 0
EOF
case_ axiom_marked_and_prose 0 0 <<'EOF'
axiom a : True -- ALLOW_AXIOM: #3 owner-authorised
/-- axiom of choice is used via Classical -/
def axiomatic : Nat := 0
def s := "axiom in a string"
EOF
case_ raw_string_with_hash 1 1 <<'EOF'
def raw : String := r#"text" /- still raw"#
theorem hidden : False := sorry
axiom bad : False
EOF
case_ raw_string_plain_and_double_hash 1 0 <<'EOF'
def a : String := r"no escapes \ here /-"
def b : String := r##"one "# inside"##
theorem t : True := by sorry
EOF
case_ raw_string_multiline 1 0 <<'EOF'
def a : String := r#"first
second /- line
third"#
theorem t : True := by sorry
EOF
case_ r_identifier_not_raw 0 0 <<'EOF'
theorem r (hr : True) : True := hr
def arr : Array Nat := #[]
EOF
case_ marker_inside_string_does_not_count 1 1 <<'EOF'
theorem t : True := by let s := "ALLOW_SORRY: #12"; sorry
axiom bad : "ALLOW_AXIOM: #1" = "ALLOW_AXIOM: #1"
EOF
case_ marker_in_block_comment_does_not_count 1 0 <<'EOF'
theorem t : True := by sorry /- ALLOW_SORRY: #12 -/
EOF
case_ marker_in_trailing_comment_counts 0 0 <<'EOF'
theorem t : True := by sorry -- ALLOW_SORRY: #12 landed incomplete on purpose
EOF
case_ interpolated_string 0 0 <<'EOF'
def m (x : Nat) : String := s!"sorry {x} /- not a comment"
theorem t : True := trivial
EOF
case_ interpolation_hole_is_code 1 0 <<'EOF'
def hidden : String := s!"{(by sorry : Nat)}"
EOF
case_ interpolation_hole_nested 1 0 <<'EOF'
def a (x : Nat) : String := s!"{x} and {toString (f "text /-" x)} and {(by admit : Nat)}"
EOF
case_ interpolation_hole_comment_brace 1 0 <<'EOF'
def hidden := s!"{/- } -/ (by sorry : Nat)}"
EOF
case_ interpolation_hole_line_comment 1 0 <<'EOF'
def hidden := s!"{ -- } comment
  (by sorry : Nat)}"
EOF
case_ keyword_ends_line 0 2 <<'EOF'
axiom
  bad : False
unsafe
  def bad2 : Nat := 0
EOF
case_ keyword_ends_line_marked 0 0 <<'EOF'
axiom -- ALLOW_AXIOM: #7 owner-authorised
  ok : True
EOF
case_ interpolation_escaped_brace 0 0 <<'EOF'
def a : String := s!"\{ sorry \} literal braces"
def b : String := m!"sorry in message text"
EOF

if [ "$fail" -eq 0 ]; then echo "guard lexer self-test OK ($n cases)"; else exit 1; fi

# --- build-lock semantics (scripts/lib/build-lock.sh) ---------------------------------
# Uses the real lock file; skipped when another process holds it for more than 5 s.
LOCK=/tmp/lean-build.lock
if ! flock -w 5 "$LOCK" true; then echo "build-lock self-test SKIPPED (lock busy)"; exit 0; fi
lfail=0
# 1. sourcing acquires the lock: an outside probe cannot take it while the holder lives
if ! bash -c '. scripts/lib/build-lock.sh; ! flock -n /tmp/lean-build.lock true'; then
  echo "FAIL [lock-acquire]: lock not held after sourcing"; lfail=1; fi
# 2. re-entrancy: a child that inherits fd 9 sources the file again without blocking
if ! timeout 5 bash -c '. scripts/lib/build-lock.sh; bash -c ". scripts/lib/build-lock.sh; echo reentered"' | grep -q reentered; then
  echo "FAIL [lock-reentrant]: nested source blocked or failed"; lfail=1; fi
# 3. an environment marker is not a lock: the spoofed caller still has to wait for the holder
if ! timeout 5 bash -c 'exec 9>>/tmp/lean-build.lock; flock 9; LEAN_SCAFFOLD_LOCKED=1 timeout 2 bash -c "exec 9>&-; . scripts/lib/build-lock.sh; echo bypassed" | grep -q bypassed && exit 1; exit 0'; then
  echo "FAIL [lock-spoof]: a caller without the descriptor got past the held lock"; lfail=1; fi
# 4. release: after the holder exits the lock is free again
if ! flock -w 5 -n "$LOCK" true; then echo "FAIL [lock-release]: lock still held after holder exited"; lfail=1; fi
if [ "$lfail" -eq 0 ]; then echo "build-lock self-test OK (4 cases)"; else exit 1; fi
