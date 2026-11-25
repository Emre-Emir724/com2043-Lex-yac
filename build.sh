bison -d mpl.y
flex mpl.l
gcc mpl.tab.c -o mpl
