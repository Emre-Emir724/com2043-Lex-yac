%{
/* MPL parser */
#include <stdio.h>
#include <stdlib.h>

int yylex();
void yyerror(const char *s);
extern int line_no;
extern char *yytext;
%}

%token START FINISH
%token NUM REAL_T LETTER_T FLAG TEXT_T
%token YES NO
%token WHEN THEN ORWHEN OTHERWISE ENDWHEN
%token WHILE DO ENDWHILE REPEAT UNTIL
%token SHOW ASK
%token RASTGELE KOCAMAN KUCUK
%token ASSIGN
%token IDENT INT_CONST REAL_CONST CHAR_CONST STRING_CONST

/* lowest to highest */
%left OR
%left AND
%right NOT
%nonassoc EQ NE LT GT LE GE
%left '+' '-'
%left '*' '/' '%'
%right UMINUS
%right '^'

%%

program : START stmts FINISH
        ;

stmts : /* nothing */
      | stmts stmt
      ;

stmt : declaration ';'
     | assignment ';'
     | show_stmt ';'
     | ask_stmt ';'
     | call ';'
     | when_stmt
     | while_stmt
     | repeat_stmt
     ;

/* num: a, b <- 5; */
declaration : type ':' var_list
            ;

type : NUM
     | REAL_T
     | LETTER_T
     | FLAG
     | TEXT_T
     ;

var_list : var
         | var_list ',' var
         ;

var : IDENT
    | IDENT ASSIGN expr
    ;

assignment : IDENT ASSIGN expr
           ;

show_stmt : SHOW '(' expr_list ')'
          ;

ask_stmt : ASK '(' id_list ')'
         ;

id_list : IDENT
        | id_list ',' IDENT
        ;

/* if - else if - else */
when_stmt : WHEN '(' expr ')' THEN stmts orwhens otherwise ENDWHEN
          ;

orwhens : /* nothing */
        | orwhens ORWHEN '(' expr ')' THEN stmts
        ;

otherwise : /* nothing */
          | OTHERWISE stmts
          ;

while_stmt : WHILE '(' expr ')' DO stmts ENDWHILE
           ;

repeat_stmt : REPEAT stmts UNTIL '(' expr ')' ';'
            ;

/* my built in functions */
builtin : RASTGELE '(' expr ',' expr ')'
        | KOCAMAN '(' expr ')'
        | KUCUK '(' expr ')'
        ;

call : IDENT '(' ')'
     | IDENT '(' expr_list ')'
     ;

expr_list : expr
          | expr_list ',' expr
          ;

expr : expr OR expr
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
     | builtin
     | call
     | IDENT
     | INT_CONST
     | REAL_CONST
     | CHAR_CONST
     | STRING_CONST
     | YES
     | NO
     ;

%%

#include "lex.yy.c"

void yyerror(const char *s)
{
    printf("Syntax error at line %d near '%s'\n", line_no, yytext);
    exit(1);
}

int main()
{
    if (yyparse() == 0)
        printf("OK\n");
    return 0;
}
