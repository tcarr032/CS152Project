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
}


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
PROGRAM: functions {printf("PROGRAM -> functions\n");}
	;
functions: {printf("functions -> epsilon\n");}
    | function functions {printf("functions -> function functions\n");}
    ;
function:   FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");}
    ;
declarations: {printf("declarations -> epsilon\n");}
    | declaration SEMICOLON declarations {printf("declarations -> declaration SEMICOLON declarations");}
    ;
declaration: identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");}
    | identifiers COLON INTEGER var {printf("declaration -> identifiers COLON INTEGER var\n");}
    | identifiers COLON ENUM L_PAREN identifiers R_PAREN {printf("declaration -> identifiers COLON ENUM L_PAREN identifiers R_PAREN\n");}
    ;
statements: 
    | statement SEMICOLON statements {printf("statements -> statement SEMICOLON statements\n");}
    ;
statement:
    | var ASSIGN expressions {printf("statement -> var ASSIGN expressions \n");}
    | IF boolexpressions THEN statements ENDIF {printf("statement -> IF boolexpressions THEN statements ENDIF \n");}
    | IF boolexpressions THEN statements ELSE statements ENDIF {printf("statement -> IF boolexpressions THEN statements ELSE statements ENDIF\n");}
    | WHILE boolexpressions BEGINLOOP statements ENDLOOP {printf("statement -> WHILE boolexpressions beginloop statements ENDLOOP\n");}
    | DO BEGINLOOP statements ENDLOOP WHILE boolexpressions {printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE boolexpressions\n");}
    | READ var {printf("statement -> READ var\n");}
    | CONTINUE {printf("statement -> CONTINUE\n");}
    | RETURN expressions {printf("statement -> RETURN\n");}
    ;
boolexpressions: relationandexpressions {printf("boolexpressions -> relationandexpressions\n");}
    | relationandexpressions OR relationandexpressions {printf("boolexpressions -> relationandexpressions OR relationandexpressions\n");}
    ;
relationandexpressions: relationexpressions {printf("relationandexpressions -> relationexpressions\n");}
    | relationexpressions AND relationexpressions {printf("relationandexpressions -> relationexpressions AND relationexpressions\n");}
    ;
relationexpressions: NOT relationexpress {printf("relationexpressions -> NOT relationexpress\n");}
    |   relationexpress {printf("relationexpressions -> relationexpress\n");}
    ;
relationexpress: expressions comps expressions {printf("relationexpress -> expressions comps expressions\n");}
    | TRUE {printf("relationexpress -> TRUE\n");}
    | FALSE {printf("relationexpress -> FALSE\n");}
    | L_PAREN boolexpressions R_PAREN {printf("relationexpress -> L_PAREN boolexpressions R_PAREN\n");}
    ;
comps: EQ EQ {printf("comps -> EQ EQ\n");}
    | LT GT {printf("comps -> LT GT\n");}
    | LT {printf("comps -> LT\n");}
    | GT {printf("comps -> GT\n");}
    | LT EQ {printf("comps -> LT EQ\n");}
    | GT EQ {printf("comps -> GT EQ\n");}
    ;
expressions: expression {printf("expressions -> expression\n");}
    |   expression COMMA expressions {printf("expressions -> expression COMMA expressions\n");}
    ;
expression: multiplicative_expression {printf("expression -> multiplicative_expression\n");}
    |   multiplicative_expression ADD multiplicative_expression {printf("expression -> multiplicative_expression ADD multiplicative_expression\n");} 
    |   multiplicative_expression SUB multiplicative_expression {printf("expression -> multiplicative_expression ADD multiplicative_expression\n");}
    ;
multiplicative_expression: term {printf("multiplicative_expression -> term\n");}
    | term MULT multiplicative_expression {printf("multiplicative_expression -> term MULT multiplicative_expression\n");}
    | term DIV multiplicative_expression {printf("multiplicative_expression -> term DIV multiplicative_expression\n");}
    | term MOD multiplicative_expression {printf("multiplicative_expression -> term MOD multiplicative_expression\n");}
    ;
term: var {printf("term -> \n");}
    | SUB var {printf("term -> SUB var\n");}
    | NUMBER {printf("term -> NUMBER\n");}
    | SUB NUMBER {printf("term -> SUB NUMBER\n");}
    | L_PAREN expression R_PAREN {printf("term -> L_PAREN expression R_PAREN\n");}
    | SUB L_PAREN expression R_PAREN {printf("term -> SUB L_PAREN expression R_PAREN\n");}
    | IDENT L_PAREN expressions R_PAREN {printf("term -> IDENT L_PAREN expressions R_PAREN\n");}
    ;
var: identifier {printf("var -> identifier\n");}
    | identifier L_SQUARE_BRACKET expressions R_SQUARE_BRACKET {printf("var -> identifier L_SQUARE_BRACKET expressions R_SQUARE_BRACKET\n");}
identifiers: identifier {printf("identifiers -> identifier\n");}
    | identifier COMMA identifiers {printf("identifiers -> identifier COMMA identifiers\n");}
    ;
identifier: {printf("identifier -> epsilon\n");}
    |IDENT COMMA {printf("identifier -> IDENT COMMA\n");}
    ;
 
%%

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
