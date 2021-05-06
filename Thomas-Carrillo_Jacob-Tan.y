%{
 #include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE* yyin;
%}

%union{
	int num_val;
	char* id_val;
}%


%start PROGRAM
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN 
%token MULT ADD DIV PLUS SUB MOD
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET  
%token <num_val> NUMBER
%token <id_val> IDENT
%left PLUS SUB
%left AND OR
%left EQ NEQ LT GT LTE GTE
%right NOT 
%left MULT DIV MOD
%right ASSIGN

%%
PROGRAM: functions {printf("PROGRAM start\n")}git
	;
functions: {printf("nothing");}
    | function functions
    ;
function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS declaration END_PARAMS BEGIN_LOCALS declaration END_LOCALS BEGIN_BODY statement END_BODY
    ;
declarations: /*epsilon*/
    | declaration SEMICOLON declarations
    ;
declaration: identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
    | identifiers COLON INTEGER
    | identifiers COLON ENUM L_PAREN identifiers R_PAREN
    ;
statements: 
    | statement SEMICOLON statements
    ;
statement:
    | vars ASSIGN expressions
    | IF boolexpressions THEN statements ENDIF
    | IF boolexpressions THEN statements ELSE statements ENDIF
    | WHILE boolexpressions beginloop statements ENDLOOP
    | DO BEGINLOOP statements ENDLOOP WHILE boolexpressions
    | READ  vars
    | CONTINUE
    | RETURN expressions
    ;
boolexpressions: relationandexpressions
    | relationandexpressions OR relationandexpressions
    ;
relationandexpressions: relationexpressions
    | relationexpressions AND relationexpressions
    ;
relationexpressions: NOT relationexpress
    |   relationexpress
    ;
relationexpress: expressions comps expressions
    | TRUE
    | FALSE
    | L_PAREN boolexpressions R_PAREN
    ;
comps: EQ EQ
    | LT GT
    | LT
    | GT
    | LT EQ
    | GT EQ
    ;
expressions: expression
    |   expression COMMA expressions
    ;
expression: multiplicative_expression
    |   multiplicative_expression ADD multiplicative_expression
    |   multiplicative_expression SUB multiplicative_expression
    ;
multiplicative_expression: term 
    | term MULT multiplicative_expression
    | term DIV multiplicative_expression
    | term MOD multiplicative_expression
    ;
terms: var
    | SUB var
    | NUMBER
    | SUB NUMBER
    | L_PAREN expression R_PAREN
    | SUB L_PAREN expression R_PAREN
    | IDENT L_PAREN expressions R_PAREN
    ;
var: identifier
    | identifier L_SQUARE_BRACKET expressions R_SQUARE_BRACKET
identifiers: identifier
    | identifier COMMA identifiers
    ;
identifier: 
    |IDENT COMMA
    ;
 


int main(int argc, char **argv){
	if(argc > 1)
	{
		yyin = fopen(argv[1], "r");
		if( yyin == NULL){
			printf("ERROR: File %s could not be read please enter a proper file\n", argv[0]);
			exit(0);
		}
	}
	yyparse();
	return 0;
}

void yyerror(const char *msg) {
	printf("Line %d, position %d: %s\n", currLine, currPos, msg);
}