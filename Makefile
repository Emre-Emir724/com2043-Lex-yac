# Build the MPL syntax analyzer (same steps as the assignment, using flex/bison -y)
LEX  ?= flex
YACC ?= bison -y

mpl: mpl.l mpl.y
	$(LEX) mpl.l
	$(YACC) mpl.y
	gcc -o mpl y.tab.c -lfl

test: mpl
	./run_tests.sh

clean:
	rm -f mpl lex.yy.c y.tab.c y.tab.h

.PHONY: test clean
