all: bf.tab.c lex.yy.c
	g++ bf.tab.c lex.yy.c -o bf -lfl

bf.tab.c:
	bison -d bf.y

lex.yy.c:
	flex bf.l

clean:
	rm bf bf.tab.h bf.tab.c lex.yy.c
