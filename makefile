all:	clean y.tab.c lex.yy.c
	gcc lex.yy.c y.tab.c -ly -lfl -o compiler

y.tab.c:
	bison -y -d compiler_hw2.y

lex.yy.c:
	flex compiler_hw2.l

clean:
	rm -f compiler lex.yy.c y.tab.c y.tab.h
