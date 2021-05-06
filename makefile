parse: Thomas-Carrillo_Jacob-Tan.y Thomas-Carrillo_Jacob-Tan.lex
	bison -v -d --file-prefix=y Thomas-Carrillo_Jacob-Tan.y
	flex Thomas-Carrillo_Jacob-Tan.lex
	gcc -o project y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o project
