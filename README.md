# MPL (My Programming Language)

COM2043 Programming Language Concepts, Project 1. MPL is a small language with a
lexical analyzer written in Lex (`mpl.l`) and a syntax analyzer written in Yacc (`mpl.y`).
The analyzer prints `OK` for a program that follows the grammar, and an error message with
the line number otherwise. It does not run programs or check types.

## Building and running

```sh
lex mpl.l          # or: flex mpl.l
yacc mpl.y         # or: bison -y mpl.y
gcc -o mpl y.tab.c -lfl
./mpl < tests/valid/full_features.mpl
```

`make` does the same three steps, and `make test` runs every example program in `tests/`
(files in `tests/valid` must print `OK`, files in `tests/invalid` must fail).

## A taste of MPL

```
#* Count down from 5 *#
start
    num: n <- 5;
    while (n > 0) do
        show(n);
        n <- n - 1;      ## arrow assignment
    endwhile
    show("liftoff!");
finish
```

## Design decisions (how MPL differs from C)

| Feature | MPL | C |
|---|---|---|
| Program block | `start` … `finish` | `int main() { … }` |
| Assignment | `x <- 5;` | `x = 5;` |
| Equality / inequality | `=` and `<>` | `==` and `!=` |
| Logic | `and`, `or`, `not` | `&&`, `\|\|`, `!` |
| Power | `^` | none |
| Declaration | `num: a, b <- 2;` (type, colon, names) | `int a, b = 2;` |
| If / else-if / else | `when (c) then … orwhen (c) then … otherwise … endwhen` | `if … else if … else` with braces |
| Loops | `while (c) do … endwhile`, `repeat … until (c);` | `while (c) { … }`, `do { … } while (c);` |
| Comments | `## line` and `#* block *#` | `//` and `/* */` |
| Booleans | `yes` / `no` | `1` / `0` |
| Chained comparison `a < b < c` | syntax error (comparisons are non-associative) | allowed |

## Lexical rules

| Token | Regular expression / lexemes |
|---|---|
| Identifier | `[a-zA-Z][a-zA-Z0-9_]*` (keywords are reserved and cannot be used as names) |
| Integer constant | `[0-9]+` |
| Real constant | `[0-9]+\.[0-9]+` (digits are required on both sides of the dot) |
| Letter constant | `'` one character or an escape `\n \t \r \0 \\ \'` `'` |
| Text constant | `"` any characters except a newline or unescaped `"` `"` |
| Flag constant | `yes`, `no` |
| Keywords | `start finish num real letter flag text yes no when then orwhen otherwise endwhen while do endwhile repeat until show ask and or not` |
| Built-in function names | `rastgele KOCAMAN kucuk` (reserved and case-sensitive: `kocaman` is an ordinary name) |
| Arithmetic operators | `+ - * / % ^` |
| Logical operators | `and or not` |
| Comparison operators | `= <> < > <= >=` |
| Assignment | `<-` |
| Punctuation | `( ) , ; :` |
| Comments | `##` to the end of the line; `#*` … `*#` across lines |
| Whitespace | spaces, tabs and newlines are ignored (newlines are counted for error messages) |

Any other character is reported as a lexical error.

## Data types

| Type | Meaning | Constants |
|---|---|---|
| `num` | integer | `42` |
| `real` | floating point | `3.14` |
| `letter` | single character | `'a'`, `'\n'` |
| `flag` | boolean | `yes`, `no` |
| `text` | string | `"hello"` |

Declarations start with the type and a colon, may list several names separated by commas,
and any name may be given a starting value with `<-`: `real: x, y <- 2.5, z;`.
Declarations can appear anywhere a statement can.

## Built-in functions

MPL's built-in function names are Turkish, and their capitalisation hints at what they do.
They are reserved words, and the grammar fixes how many arguments each one takes, so a
wrong argument count is a syntax error. They can be used anywhere an expression can.

| Function | Meaning | Arguments |
|---|---|---|
| `rastgele(a, b)` | a random number between `a` and `b` ("rastgele" = random) | exactly 2 |
| `KOCAMAN(t)` | text `t` in UPPER CASE ("kocaman" = huge) | exactly 1 |
| `kucuk(t)` | text `t` in lower case ("küçük" = small) | exactly 1 |

```
num: zar <- rastgele(1, 6);
text: loud <- KOCAMAN("hello"), quiet <- kucuk("HELLO");
```

## Operator precedence and associativity

From highest to lowest. This is the order of the `%left`/`%right`/`%nonassoc`
declarations in `mpl.y` (which lists them lowest first).

| Level | Operators | Associativity |
|---|---|---|
| 1 (highest) | `( )` grouping, function and built-in calls | n/a |
| 2 | `^` | right (`2 ^ 3 ^ 2` = `2 ^ (3 ^ 2)`) |
| 3 | unary `-` | right (`-x ^ 2` = `-(x ^ 2)`) |
| 4 | `* / %` | left |
| 5 | `+ -` | left |
| 6 | `= <> < > <= >=` | non-associative (`a < b < c` is an error) |
| 7 | `not` | right |
| 8 | `and` | left |
| 9 (lowest) | `or` | left |

So arithmetic binds tighter than comparison, which binds tighter than logic:
`not a + 1 > b and c` parses as `(not ((a + 1) > b)) and c`.

## Grammar (EBNF)

`{ x }` means zero or more, `[ x ]` means optional, terminals are in quotes.

```ebnf
program        = "start" , { statement } , "finish" ;

statement      = declaration , ";"
               | assignment , ";"
               | show_stmt , ";"
               | ask_stmt , ";"
               | call , ";"
               | when_stmt
               | while_stmt
               | repeat_stmt ;

declaration    = type , ":" , decl_item , { "," , decl_item } ;
type           = "num" | "real" | "letter" | "flag" | "text" ;
decl_item      = IDENT , [ "<-" , expr ] ;

assignment     = IDENT , "<-" , expr ;

show_stmt      = "show" , "(" , expr , { "," , expr } , ")" ;
ask_stmt       = "ask" , "(" , IDENT , { "," , IDENT } , ")" ;

when_stmt      = "when" , "(" , expr , ")" , "then" , { statement } ,
                 { "orwhen" , "(" , expr , ")" , "then" , { statement } } ,
                 [ "otherwise" , { statement } ] ,
                 "endwhen" ;

while_stmt     = "while" , "(" , expr , ")" , "do" , { statement } , "endwhile" ;
repeat_stmt    = "repeat" , { statement } , "until" , "(" , expr , ")" , ";" ;

call           = IDENT , "(" , [ expr , { "," , expr } ] , ")" ;

expr           = or_expr ;
or_expr        = and_expr , { "or" , and_expr } ;
and_expr       = not_expr , { "and" , not_expr } ;
not_expr       = "not" , not_expr | comparison ;
comparison     = additive , [ comp_op , additive ] ;
comp_op        = "=" | "<>" | "<" | ">" | "<=" | ">=" ;
additive       = term , { ( "+" | "-" ) , term } ;
term           = unary , { ( "*" | "/" | "%" ) , unary } ;
unary          = "-" , unary | power ;
power          = primary , [ "^" , unary ] ;
primary        = "(" , expr , ")" | builtin_call | call | IDENT | constant ;
builtin_call   = "rastgele" , "(" , expr , "," , expr , ")"
               | "KOCAMAN" , "(" , expr , ")"
               | "kucuk" , "(" , expr , ")" ;
constant       = INT_CONST | REAL_CONST | CHAR_CONST | STRING_CONST | "yes" | "no" ;
```

The EBNF above spells the precedence out as one rule per level. `mpl.y` writes the same
language as one ambiguous `expr` rule and settles it with precedence declarations,
which is the usual Yacc style. Yacc builds it with no shift/reduce or reduce/reduce conflicts.

## Error handling

The analyzer stops at the first error and prints where it is:

```
Syntax error at line 3 near '='
Syntax error at line 4: unexpected end of file
Lexical error at line 2 near '@': unknown character
Lexical error at line 5: unterminated block comment (missing *#)
```

## Example programs

- `tests/valid/full_features.mpl` uses every feature (all types, every operator, `when`/`orwhen`/`otherwise`, both loops, nesting, `show`, `ask`).
- `tests/valid/builtins.mpl` uses the built-in functions.
- `tests/valid/countdown.mpl` and `tests/valid/minimal.mpl` are small valid programs.
- `tests/invalid/*.mpl` each contain one deliberate error, named after the error
  (missing `;`, C-style `=` assignment, missing `endwhen`, unbalanced parentheses,
  a keyword used as a name, an identifier starting with a digit, `* *`, missing `finish`,
  `while` without parentheses, an unknown character, an unclosed comment, a chained comparison, and built-ins called with the wrong number of arguments or used as a variable name).
