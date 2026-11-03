lex mpl.l
yacc mpl.y
gcc -o mpl y.tab.c -lfl
