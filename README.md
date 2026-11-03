# MPL - My Programming Language

COM2043 Project 1. A small language made with lex and yacc. It only checks the syntax:
it prints OK if the program is correct, or a syntax error with the line number.

## How to run

```
sh build.sh
./mpl < tests/valid/full_features.mpl
```

build.sh just runs `lex mpl.l`, `yacc mpl.y` and `gcc -o mpl y.tab.c -lfl`.
`./test.sh` runs all the example programs in the tests folder.

## Example

```
start
    num: n <- 5;
    while (n > 0) do
        show(n);
        n <- n - 1;
    endwhile
    show("liftoff!");
finish
```

## The language

- A program starts with `start` and ends with `finish`.
- Every statement ends with `;`
- Comments: `## comment` for one line, `#* comment *#` for more lines.
- Types: `num` (integer), `real` (float), `letter` (char), `flag` (true/false, written `yes`/`no`), `text` (string).
- Declaring: `num: a, b <- 5;` (you can declare more than one and give a starting value).
- Assignment uses an arrow: `a <- a + 1;`
- Variable names start with a letter, then letters, digits or `_`. Regex: `[a-zA-Z][a-zA-Z0-9_]*`. Keywords can't be names.
- Numbers: `12`, `3.5`. Letters: `'a'`. Text: `"hello"`.
- Math: `+ - * / %`, `^` for power, `-x`
- Compare: `=` equal, `<>` not equal, `< > <= >=`
- Logic: `and`, `or`, `not`
- If: `when (cond) then ... orwhen (cond) then ... otherwise ... endwhen` (orwhen and otherwise are optional)
- Loops: `while (cond) do ... endwhile` and `repeat ... until (cond);`
- Print and input: `show(a, "text");` and `ask(a);`

### My built in functions

- `rastgele(a, b)` gives a random number between a and b
- `KOCAMAN(t)` makes text uppercase
- `kucuk(t)` makes text lowercase

They have to get the right number of arguments, `rastgele(1)` is a syntax error.

### Operator precedence (high to low)

1. `( )`
2. `^` (right to left)
3. `-x` unary minus
4. `* / %` (left to right)
5. `+ -` (left to right)
6. `= <> < > <= >=` (can't chain them, `a < b < c` is an error)
7. `not`
8. `and`
9. `or`

## Grammar (EBNF)

```
program      = "start" { statement } "finish"
statement    = declaration ";" | assignment ";" | show ";" | ask ";" | call ";"
             | when | while | repeat
declaration  = type ":" var { "," var }
type         = "num" | "real" | "letter" | "flag" | "text"
var          = IDENT [ "<-" expr ]
assignment   = IDENT "<-" expr
show         = "show" "(" expr { "," expr } ")"
ask          = "ask" "(" IDENT { "," IDENT } ")"
when         = "when" "(" expr ")" "then" { statement }
               { "orwhen" "(" expr ")" "then" { statement } }
               [ "otherwise" { statement } ] "endwhen"
while        = "while" "(" expr ")" "do" { statement } "endwhile"
repeat       = "repeat" { statement } "until" "(" expr ")" ";"
call         = IDENT "(" [ expr { "," expr } ] ")"
builtin      = "rastgele" "(" expr "," expr ")" | "KOCAMAN" "(" expr ")" | "kucuk" "(" expr ")"

expr         = expr "or" expr | expr "and" expr | "not" expr
             | expr compare expr
             | expr ( "+" | "-" | "*" | "/" | "%" | "^" ) expr
             | "-" expr | "(" expr ")" | builtin | call | IDENT | constant
compare      = "=" | "<>" | "<" | ">" | "<=" | ">="
constant     = INT | REAL | CHAR | STRING | "yes" | "no"
```

The precedence list above decides how `expr` is grouped (it's the `%left` / `%right` part in mpl.y).

## Tests

- `tests/valid/` programs that should print OK
- `tests/invalid/` programs with a mistake in them, the file name says what the mistake is
