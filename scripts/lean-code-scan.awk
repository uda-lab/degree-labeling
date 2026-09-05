# Comment- and string-aware scanner over Lean sources, shared by scripts/check-no-sorry.sh
# (mode=sorry) and scripts/check-no-custom-axiom.sh (mode=axiom). Invoke as
#     awk -v mode=sorry -f scripts/lean-code-scan.awk FILE...
# and it prints `file:line:content` for every violating line; no output means clean.
#
# Lexing rules (state is reset per file):
#   * block comments `/- … -/` nest and may span lines; line comments `-- …` run to end of line;
#   * string literals `"…"` (with `\"` escapes, spanning lines — Lean allows raw newlines in
#     strings) are opaque: their content is replaced by `""` in the code stream, so a `/-`,
#     `--`, `sorry` or `axiom` inside a string neither opens a comment nor trips a rule;
#   * interpolated strings (`s!"…"`, `m!"…"`, any `<ident>!"…"`) are opaque EXCEPT their
#     `{…}` holes, which are Lean terms and are lexed as code — including nested comments
#     (a `}` inside `/- … -/` does not close the hole), nested strings and nested holes;
#     `\{` is a literal brace;
#   * raw string literals `r"…"`, `r#"…"#`, `r##"…"##` … are opaque: no escapes, closed only
#     by `"` followed by the same number of `#`; recognised where the `r` cannot be part of
#     an identifier;
#   * character literals `'x'` / `'\n'` are opaque, recognised only where a `'` cannot be part
#     of an identifier (`h'` stays an identifier).
# A declaration keyword may end its line (`axiom` ⏎ `bad : False`); the axiom rule therefore
# also fires on a code line that ends with the keyword.
# The ALLOW_ markers are honoured ONLY in the trailing line comment of the violating line
# (`… := sorry -- ALLOW_SORRY: #12 reason`), never inside a string or a block comment.
BEGIN { q = "\047" }
FNR == 1 { depth = 0; inStr = 0; rawHashes = -1; interp = 0; hole = 0; holeStr = 0; holeCmt = 0 }
{
  line = $0; code = ""; inLine = 0; trailing = ""
  n = length(line); i = 1
  while (i <= n) {
    c = substr(line, i, 1); two = substr(line, i, 2)
    if (inStr && hole > 0) {                       # inside an interpolation hole: Lean code
      if (holeCmt > 0) {                            # block comment inside the hole
        if (two == "-/") { holeCmt--; i += 2; continue }
        if (two == "/-") { holeCmt++; i += 2; continue }
        i++; continue
      }
      if (inLine) { i++; continue }                # `--` inside a hole: rest of line is comment
      if (holeStr) { if (c == "\\") { i += 2; continue } if (c == "\"") holeStr = 0; i++; continue }
      if (two == "/-") { holeCmt = 1; i += 2; continue }
      if (two == "--") { inLine = 1; trailing = substr(line, i); i += 2; continue }
      if (c == "\"") { holeStr = 1; code = code "\"\""; i++; continue }
      if (c == "{") { hole++ } else if (c == "}") { hole--; if (hole == 0) { code = code " "; i++; continue } }
      code = code c; i++; continue
    }
    if (inStr) {
      if (rawHashes >= 0) {                        # raw string: `"` + rawHashes × `#` closes it
        if (c == "\"" && substr(line, i + 1, rawHashes) == hashes(rawHashes)) {
          i += 1 + rawHashes; inStr = 0; rawHashes = -1; code = code "\"\""; continue
        }
        i++; continue
      }
      if (c == "\\") { i += 2; continue }
      if (interp && c == "{") { hole = 1; code = code " "; i++; continue }
      if (c == "\"") { inStr = 0; interp = 0; code = code "\"\"" }
      i++; continue
    }
    if (depth > 0) {
      if (two == "-/") { depth--; i += 2; continue }
      if (two == "/-") { depth++; i += 2; continue }
      i++; continue
    }
    if (inLine) { i++; continue }
    if (two == "--") { inLine = 1; trailing = substr(line, i); i += 2; continue }
    if (two == "/-") { depth++; i += 2; continue }
    if (c == "\"") { inStr = 1; rawHashes = -1; interp = (code ~ /[A-Za-z0-9_]![[:space:]]*$/) ? 1 : 0; i++; continue }
    if (c == "r" && (code == "" || substr(code, length(code), 1) !~ /[A-Za-z0-9_.!?]/)) {
      j = i + 1; h = 0
      while (substr(line, j, 1) == "#") { h++; j++ }
      if (substr(line, j, 1) == "\"") { inStr = 1; rawHashes = h; interp = 0; i = j + 1; continue }
    }
    if (c == q) {
      prev = (code == "") ? "" : substr(code, length(code), 1)
      if (prev == "" || (prev !~ /[A-Za-z0-9_.!?]/ && prev != q)) {
        if (substr(line, i + 1, 1) == "\\" && substr(line, i + 3, 1) == q) { code = code "''"; i += 4; continue }
        if (substr(line, i + 1, 1) != q && substr(line, i + 2, 1) == q) { code = code "''"; i += 3; continue }
      }
    }
    code = code c; i++
  }
  if (mode == "sorry") {
    if (code ~ /(^|[^A-Za-z0-9_])(sorry|admit)([^A-Za-z0-9_]|$)/ && trailing !~ /ALLOW_SORRY: .*#[0-9]+/)
      printf "%s:%d:%s\n", FILENAME, FNR, line
  } else if (mode == "axiom") {
    if (code ~ /^[[:space:]]*(@\[[^]]*\][[:space:]]*)*((private|protected|noncomputable|scoped|local)[[:space:]]+)*(axiom|constant|opaque|unsafe)([[:space:]]|$)/ && trailing !~ /ALLOW_AXIOM: .*#[0-9]+/)
      printf "%s:%d:%s\n", FILENAME, FNR, line
  } else {
    print "lean-code-scan.awk: unknown mode '" mode "'" > "/dev/stderr"; exit 2
  }
}
function hashes(k,   s) { s = ""; while (k-- > 0) s = s "#"; return s }
