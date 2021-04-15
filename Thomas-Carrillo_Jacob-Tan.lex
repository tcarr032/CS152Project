%{
	int currLine = 1, currPos = 1;
%}
DIGIT [0-9]

%%
## Here we are going to do the operators
%%

int main(int argc, char ** argv)
{
	if(argc >= 2)
	{
			yyin = fopen(argv[1], "r");
			if( yyin == NULL)
			{
					yyin = stdin;
			}
	}
	else
	{
		yyin = stdin;
	}
yylex();
printf("current end of program)
}
