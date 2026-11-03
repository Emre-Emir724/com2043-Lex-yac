%{
/*
 * mpl.y - Syntax analyzer for MPL (My Programming Language)
 *
 * Reads an MPL program from standard input and prints "OK" when it
 * matches the grammar, or a syntax error message with the line number.
 *
 * Build:  lex mpl.l && yacc mpl.y && gcc -o mpl y.tab.c -lfl
 * Run:    ./mpl < program.mpl
 */
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *msg);
extern int line_no;
extern char *yytext;
%}

/* ---------- Tokens ---------- */
%token START FINISH
%token NUM REAL_T LETTER_T FLAG TEXT_T
%token YES NO
%token WHEN THEN ORWHEN OTHERWISE ENDWHEN
%token WHILE DO ENDWHILE REPEAT UNTIL
%token SHOW ASK
%token RASTGELE KOCAMAN KUCUK
%token ASSIGN
%token IDENT INT_CONST REAL_CONST CHAR_CONST STRING_CONST

/* ---------- Precedence and associativity (lowest first) ---------- */
%left     OR
%left     AND
%right    NOT
%nonassoc EQ NE LT GT LE GE
%left     '+' '-'
%left     '*' '/' '%'
%right    UMINUS
%right    '^'

%start program

%%

/* ---------- Program structure ---------- */
program
    : START stmt_list FINISH
    ;

stmt_list
    : /* empty */
    | stmt_list stmt
    ;

stmt
    : declaration ';'
    | assignment ';'
    | show_stmt ';'
    | ask_stmt ';'
    | call ';'
    | when_stmt
    | while_stmt
    | repeat_stmt
    ;

/* ---------- Declarations:  num: a, b <- 5; ---------- */
declaration
    : type ':' decl_list
    ;

type
    : NUM
    | REAL_T
    | LETTER_T
    | FLAG
    | TEXT_T
    ;

decl_list
    : decl_item
    | decl_list ',' decl_item
    ;

decl_item
    : IDENT
    | IDENT ASSIGN expr
    ;

/* ---------- Assignment:  x <- expr; ---------- */
assignment
    : IDENT ASSIGN expr
    ;

/* ---------- Input / output ---------- */
show_stmt
    : SHOW '(' expr_list ')'
    ;

ask_stmt
    : ASK '(' ident_list ')'
    ;

ident_list
    : IDENT
    | ident_list ',' IDENT
    ;

/* ---------- Conditional:  when (c) then ... orwhen (c) then ... otherwise ... endwhen ---------- */
when_stmt
    : WHEN '(' expr ')' THEN stmt_list orwhen_list otherwise_part ENDWHEN
    ;

orwhen_list
    : /* empty */
    | orwhen_list ORWHEN '(' expr ')' THEN stmt_list
    ;

otherwise_part
    : /* empty */
    | OTHERWISE stmt_list
    ;

/* ---------- Loops ---------- */
while_stmt
    : WHILE '(' expr ')' DO stmt_list ENDWHILE
    ;

repeat_stmt
    : REPEAT stmt_list UNTIL '(' expr ')' ';'
    ;

/* ---------- Built-in functions ----------
 *   rastgele(a, b)  random number between a and b   (exactly 2 arguments)
 *   KOCAMAN(t)      text t in upper case             (exactly 1 argument)
 *   kucuk(t)        text t in lower case             (exactly 1 argument)
 */
builtin_call
    : RASTGELE '(' expr ',' expr ')'
    | KOCAMAN '(' expr ')'
    | KUCUK '(' expr ')'
    ;

/* ---------- Function calls:  name(arg, arg) ---------- */
call
    : IDENT '(' ')'
    | IDENT '(' expr_list ')'
    ;

expr_list
    : expr
    | expr_list ',' expr
    ;

/* ---------- Expressions ---------- */
expr
    : expr OR expr
    | expr AND expr
    | NOT expr
    | expr EQ expr
    | expr NE expr
    | expr LT expr
    | expr GT expr
    | expr LE expr
    | expr GE expr
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | expr '%' expr
    | expr '^' expr
    | '-' expr %prec UMINUS
    | '(' expr ')'
    | builtin_call
    | call
    | IDENT
    | constant
    ;

constant
    : INT_CONST
    | REAL_CONST
    | CHAR_CONST
    | STRING_CONST
    | YES
    | NO
    ;

%%

#include "lex.yy.c"

void yyerror(const char *msg)
{
    if (yytext != NULL && yytext[0] != '\0')
        printf("Syntax error at line %d near '%s'\n", line_no, yytext);
    else
        printf("Syntax error at line %d: unexpected end of file\n", line_no);
    exit(1);
}

int main(void)
{
    if (yyparse() == 0)
        printf("OK\n");
    return 0;
}
