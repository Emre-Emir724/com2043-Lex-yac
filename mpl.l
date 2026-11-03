%{
/* MPL lexer */
#include <stdio.h>
#include <stdlib.h>

int line_no = 1;
%}

%option noyywrap

%x COMMENT

%%

"##".*          ;
"#*"            { BEGIN(COMMENT); }
<COMMENT>"*#"   { BEGIN(INITIAL); }
<COMMENT>\n     { line_no++; }
<COMMENT>.      ;
<COMMENT><<EOF>> { printf("Error: comment is not closed with *#\n"); exit(1); }

"start"         { return START; }
"finish"        { return FINISH; }
"num"           { return NUM; }
"real"          { return REAL_T; }
"letter"        { return LETTER_T; }
"flag"          { return FLAG; }
"text"          { return TEXT_T; }
"yes"           { return YES; }
"no"            { return NO; }
"when"          { return WHEN; }
"then"          { return THEN; }
"orwhen"        { return ORWHEN; }
"otherwise"     { return OTHERWISE; }
"endwhen"       { return ENDWHEN; }
"while"         { return WHILE; }
"do"            { return DO; }
"endwhile"      { return ENDWHILE; }
"repeat"        { return REPEAT; }
"until"         { return UNTIL; }
"show"          { return SHOW; }
"ask"           { return ASK; }
"and"           { return AND; }
"or"            { return OR; }
"not"           { return NOT; }

"rastgele"      { return RASTGELE; }
"KOCAMAN"       { return KOCAMAN; }
"kucuk"         { return KUCUK; }

"<-"            { return ASSIGN; }
"<="            { return LE; }
">="            { return GE; }
"<>"            { return NE; }
"="             { return EQ; }
"<"             { return LT; }
">"             { return GT; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"%"             { return '%'; }
"^"             { return '^'; }
"("             { return '('; }
")"             { return ')'; }
","             { return ','; }
";"             { return ';'; }
":"             { return ':'; }

[0-9]+"."[0-9]+         { return REAL_CONST; }
[0-9]+                  { return INT_CONST; }
\'(.|\\n|\\t)\'         { return CHAR_CONST; }
\"[^"\n]*\"             { return STRING_CONST; }
[a-zA-Z][a-zA-Z0-9_]*   { return IDENT; }

[ \t\r]+        ;
\n              { line_no++; }

.               { printf("Error at line %d: unknown character '%s'\n", line_no, yytext); exit(1); }

%%
