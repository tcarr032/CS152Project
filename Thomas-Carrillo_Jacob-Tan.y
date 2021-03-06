%{
 #include <stdio.h>
 #include <stdbool.h>
 #include <stdlib.h>
 #include <map>
 #include <string.h>
 #include <set>

 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 int labelCount = 0;
 int tempCount = 0;
 std::map<std::string, std::string> varTemp;
 std::map<std::string, int> arrSize;
 bool mainFunc;
 std::set<std::string> funcs;
 std::set<std::string> reserved {"NUMBER", "IDENT", "RETURN", "FUNCTION", "SEMICOLON", "BEGIN_PARAMS", "END_PARAMS", "BEGIN_LOCALS", "END_LOCALS", "BEGIN_BODY", 
    "END_BODY", "BEGINLOOP", "ENDLOOP", "COLON", "INTEGER", "COMMA", "ARRAY", "L_SQUARE_BRACKET", "R_SQUARE_BRACKET", "L_PAREN", "R_PAREN", "IF", "ELSE", "THEN", 
    "CONTINUE", "ENDIF", "OF", "READ", "WRITE", "DO", "WHILE", "FOR", "TRUE", "FALSE", "ASSIGN", "EQ", "NEQ", "LT", "LTE", "GT", "GTE", "ADD", "SUB", "MULT", "DIV", 
    "MOD", "AND", "OR", "NOT", "Function", "Declarations", "Declaration", "Vars", "Var", "Expressions", "Expression", "Idents", "Ident", "Bool-Expr", 
    "Relation-And-Expr", "Relation-Expr-Inv", "Relation-Expr", "Comp", "Multiplicative-Expr", "Term", "Statements", "Statement"};

 FILE* yyin;
 std::string new_temp();
 std::string new_label();
 int yylex();
%}
 
%union{
	int num_val;
	char* id_val;
    struct S {
        char* code;
    } statement;
    struct E {
        char* place;
        char* code;
        bool arr;
    } expression;
}

%error-verbose
%start Program
%token FOR FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE RETURN 
%token MULT ADD DIV SUB MOD
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET  

%token <num_val> NUMBER
%token <id_val> IDENT

%left ADD SUB
%left AND OR
%left EQ NEQ LT GT LTE GTE
%right NOT 
%left MULT DIV MOD
%right ASSIGN

%type <expression> function FuncIdent declarations declaration vars var expressions expression identifiers identifier
%type <expression> boolexpressions relationandexpressions relationexpress relationexpressions comps multiplicative_expression term
%type <statement> statements statement

%%
Program: %empty
    {
        if (!mainFunc) {
            printf ("No main function declared!\m");
        }
    }
    | function Program
    {}
    ;
function:   FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY 
    {
    std::string temp = "func ";
    temp.append($2.place);
    temp.append("\n");
    std::string s = $2.place;
    if (s == "main") {
        mainFunc = true;
    }
    temp.append($5.code);
    std::string decs = $5.code;
    int decNum = 0;
    while(decs.find(".") != std::string::npos) {
        int position = decs.find(".");
        decs.replace(position,1,"=");
        std::string part = ", $" + std::to_string(decNum) + "\n";
        decNum++;
        decs.replace(decs.find("\n", position), 1, part)
    }
    temp.append(decs);

    temp.append($8.code);
    std::string statements = $11.code;
    if (statements.find("continue") != std::string::npos) {
        printf("ERROR: Loop continued outside function. %s\n", $2.place);
    }
    temp.append(statements);
    temp.append("endfunc\n\n");
    printf(temp.c_str());
    };


declarations: %empty
    {
        $$.place = strdup("");
        $$.code = strdup("");
    }
    | declaration SEMICOLON declarations 
    {
        std::string temp;
        temp.append($3.code);
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    }
    ;
declaration: identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
    {
        size_t left = 0;
        size_t right = 0;
        std::string parser($1.place); /* identifiers */
        std::string temp;
        bool ex = false;
        while(!ex) 
        {
            right = parse.find("|", left);
            temp.append(".[] ");
            if (right == std::string::npos) 
            {
                std::string ident = parse.substr(left, right);
                if (reserved.find(ident)) != reserved.end())   /* matches a reserved word in reserved list */
                {
                    printf("Identifier %s is a reserved word.\n", ident.c_str());
                }
                if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end())   
                {
                    printf("Identifier %s is already declared.\n");
                }
                else 
                {
                    if ($5 <= 0) { /* number */
                        printf("Declaring array ident %s size <= 0,\n", ident.c_str());
                    }
                    varTemp[ident] = ident;
                    arrSize[ident] = $5; /* number */
                }
                temp.append(ident);
                ex = true;

            }
            else
            {
                std::string ident = parse.substr(left, right-left);
                if (reserved.find(ident)) != reserved.end())   /* matches a reserved word in reserved list */
                {
                    printf("Identifier %s is a reserved word.\n", ident.c_str());
                }
                if (funcs.find(ident) != funcs.end() || varTemp.find(ident) != varTemp.end())   
                {
                    printf("Identifier %s is already declared.\n");
                }
                else 
                {
                    if ($5 <= 0) { /* number */
                        printf("Declaring array ident %s size <= 0,\n", ident.c_str());
                    }
                    varTemp[ident] = ident;
                    arrSize[ident] = $5; /* number */
                }
                temp.append(ident);
                left = right + 1;
            }
            temp.append(", ");
            temp.append(std::to_string($5));
            temp.append("\n");
        }
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    }
    | identifiers COLON INTEGER
    {
        std::string temp;
        temp.append($1.code);
        //temp.append($3.place);
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");

    }
    | identifiers COLON ENUM L_PAREN identifiers R_PAREN
    {
        std::string temp;
        temp.append($1.code);
        temp.append($5.code);
        $$.code = strdup(temp.c_str());
        $$.place = strdup("");
    }
    ;
statements: 
    | statement SEMICOLON statements
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        $$.code = strdup(temp.c_str());
    }
    ;
statement:
    | var ASSIGN expressions
    {
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        std::string middle = $3.place;
        if($1.arr && $3.arr)
        {
            temp += "[]=";
        } else if ($1.arr)  
        {
            temp += "[]=";
        } else if ($3.arr)  
        {
            temp += "= ";
        } else  
        {
            temp += "= ";
        }

        temp.append($1.place);
        temp.append(", ");
        temp.append(middle);
        temp += "\n"
        $$.code = strdup(temp.c_str());
    }
    | IF boolexpressions THEN statements ENDIF
    {
        std::string ifS = new_label();
        std::string after = new_label();
        std::string temp;
        temp.append($2.code);
        temp = temp + "?:= " + ifS + ", " + $2.place + "\n";
        temp = temp + ":= " + after + "\n";
        temp = temp + ": " + ifS + "\n";
        temp.append($4.code);
        temp = temp + ": " + after + "\n";
        $$.code = strdup(temp.c_str());
    }
    | IF boolexpressions THEN statements ELSE statements ENDIF {
        std::string ifS = new_label();
        std::string after = new_label();
        std::string temp;
        temp.append($2.code);
        temp = temp + "?:-= " + ifS + ", " + $2.place + "\n";
        temp = temp + ":= " + after + "\n";
        temp = temp + ": " + ifS + "\n";
        temp.append($4.append);
        temp = temp + ": " + after + "\n";
        temp.append($6.code);
        $$.code = strdup(temp.c_str());
    }
    | WHILE boolexpressions BEGINLOOP statements ENDLOOP 
    {
        std::string ifS = new_label();
        std::string after = new_label();
        std::string temp;
        temp.append($2.code);
        temp = temp + "?:= " + ifS + ", " + $2.place + "\n";
        temp = temp + ":= " + after + "\n";
        temp = temp + ": " + ifS + "\n";
        temp.append($4.code);
        temp = temp + ": " + after + "\n";
        $$.code = strdup(temp.c_str());

    }
    | DO BEGINLOOP statements ENDLOOP WHILE boolexpressions
    {
        std::string ifS = new_label();
        std::string after = new_label();
        std::string temp;
        temp.append($6.code);
        temp = temp + "?:= " + ifS + ", " + $6.place + "\n";
        temp = temp + ":= " + after + "\n";
        temp = temp + ": " + ifS + "\n";
        temp.append($3.code);
        temp = temp + ": " + after + "\n";
        $$.code = strdup(temp.c_str());
    }
    | READ vars 
    {
        std::string temp;
        temp.append($2.code);
        size_t pos = temp.find("|", 0);
        while (pos != std::string::npos)
        {
            temp.replace(pos, 1, ".<");
            pos = temp.find("|", pos);
        }
        $$.code = strdup(temp.c_str());
    }
    | WRITE vars
    {
        std::string temp;
        temp.append($2.code);
        size_t pos = temp.find("|", 0);
        while (pos != std::string::npos)
        {
            temp.replace(pos, 1, ".>");
            pos = temp.find("|", pos);
        }
        $$.code = strdup(temp.c_str());
    }
    | CONTINUE 
        {
            $$.code = strdup{"continue\n"};
        }
    | RETURN expressions {
        std::string temp;
        std::string dst = new_temp();

        temp.append($2.code);
        temp.append("ret ");git 
        temp.append($2.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
    }
    ;
boolexpressions: relationandexpressions
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | relationandexpressions OR relationandexpressions
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n";
        temp += "|| " + dest + ", ";
        temp.append($1.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.code = strdup(dst.c_str());
    }
    ;
relationandexpressions: relationexpressions
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | relationexpressions AND relationandexpressions
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n";
        temp += "&& " + dest + ", ";
        temp.append($1.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.code = strdup(dst.c_str());
    }
    ;
relationexpressions: NOT relationexpress
    {
        std:string temp;
        std:string dst = new_temp();
        temp.append($2.code);
        temp += ". " + dst + "\n";
        temp += "! " + dst + ", ";
        temp.append($2.place);
        temp.append("\n");
        $$.code = strdup(temp.c_str());
        $$.code = strdup(dst.c_str());
    }
    |   relationexpress
    {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    ;
relationexpress: expressions comps expressions 
    {
        std::string dst = new_label();
        std::string temp;
        temp.append($1.code);
        temp.append($3.code);
        temp = temp + ". " + dst + "\n" + $2.place + dst + ", " + $1.place + ", " + $3.place +"\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | TRUE 
    {
        std::string temp;
        temp.append("1");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | FALSE 
    {
        std::string temp;
        temp.append("0");
        $$.code = strdup("");
        $$.place = strdup(temp.c_str());
    }
    | L_PAREN boolexpressions R_PAREN
    {
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
    }
    ;
comps: EQ
    {
        $$.code = strdup("");
        $$.place = strdup("== ");
    }
    | NEQ
    {
        $$.code = strdup("");
        $$.place = strdup("!= ");
    }
    | LT
    {
        $$.code = strdup("");
        $$.place = strdup("< ");
    }
    | GT
    {
        $$.code = strdup("");
        $$.place = strdup("> ");
    }
    | LTE
    {
        $$.code = strdup("");
        $$.place = strdup("<= ");
    }
    | GTE
    {
        $$.code = strdup("");
        $$.place = strdup(">= ");
    }
    ;
expressions: expression 
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp +=
        $$.code = strdup(temp.c_str);
    }
    |   expression COMMA expressions 
    {
        std::string temp;
        std::string dst = new_temp;
        temp.append($1.code);
        temp.append($3.code);
        temp = temp + ". " + dst + "\n";
    }
    ;
expression: multiplicative_expression
    {
        std::string temp;
        temp.append($1.code);
        $$.code = strdup(temp.c_str());
    }
    |   multiplicative_expression ADD expression 
    {
        std::string temp;
        std::string dest = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n";
        temp += "+ " + dst + ", ";
        temp.append($1.place);
        temp += ", ";
        temp.append($3.place);
        temp += "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    |   multiplicative_expression SUB expression
    {
        std::string temp;
        std::string dest = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp += ". " + dst + "\n";
        temp += "- " + dst + ", ";
        temp.append($1.place);
        temp += ", ";
        temp.append($3.place);
        temp += "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    ;
multiplicative_expression: term
    {
      
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | term MULT multiplicative_expression
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp.append(", ");
        temp.append(dst);
        temp.append("\n");
        temp += "* " + dst + ", ";
        temp.append($1.place);
        temp += ", ";
        temp.append($3.place);
        temp += "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | term DIV multiplicative_expression
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp.append(", ");
        temp.append(dst);
        temp.append("\n");
        temp += "/ " + dst + ", ";
        temp.append($1.place);
        temp += ", ";
        temp.append($3.place);
        temp += "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | term MOD multiplicative_expression
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append($1.code);
        temp.append($3.code);
        temp.append(", ");
        temp.append(dst);
        temp.append("\n");
        temp += "% " + dst + ", ";
        temp.append($1.place);
        temp += ", ";
        temp.append($3.place);
        temp += "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    ;
term: var {
        $$.code = strdup($1.code);
        $$.place = strdup($1.place);
    }
    | SUB var {
        std::string dst = new_temp();
        std::string temp;
        if($2.arr){
            temp.append($2.code);
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp += "=[] " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
            /* maybe append $2.code */
        } else {
            temp.append(". ");
            temp.append(dst);
            temp.append("\n");
            temp += "= " + dst + ", ";
            temp.append($2.place);
            temp.append("\n");
            temp.append($2.code);
        }
        if(varTemp.find($2.place) != varTemp.end()){
            varTemp[$2.place] = dst;
        }
    }
    | NUMBER 
    {
        std::string temp;
        std::string dst = new_temp();
        temp.append(". ");
        temp.append(dst);
        temp.append("\n");
        temp = temp + "= " + dst + ", " std::to_string($1) + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = stdup(dst.c_str());
    }
    | SUB NUMBER
    {
        std::string dst = new_temp();
        std::string temp;
        temp.append(". ");
        temp.append(dst);
        temp.append("\n");
        temp = temp + "= " + dst + ", -" + std:to_string($2) + "\n";
        $$.code = strdup(temp.c_str());
        $$.place = strdup(dst.c_str());
    }
    | L_PAREN expression R_PAREN
    {
        $$.code = strdup($2.code);
        $$.place = strdup($2.place);
    }
    | SUB L_PAREN expression R_PAREN
    {
        std::string temp;
        temp.append($3.code);
        temp.append("* ");
        temp.append($3.place);
        temp.append(", ");
        temp.append($3.place);
        temp.append(", -1\n");
        $$.code = strdup(temp.c_str());
        $$.place = strdup($3.place);
    }
    | IDENT L_PAREN expressions R_PAREN 
    ;
vars: var 
    {
        std::string temp;
        temp.append($1.code);
        $$.code = strdup(temp.c_str());
    }
    | var COMMA vars 
    {
        std::string temp;
        std::string dst = new_temp;
        temp.append($1.code);
        temp.append($3.code);
        temp = temp + ". " + dst + "\n" 
    }
    ;
var: identifier
    {
        std::string temp;
        $$.code = strdup("");
        std::string ident = $1.place;
        if ( funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end())
        {
            printf("Identifier %s is not declared.\n", ident.c_str());
        }
        else if (arrSize[ident] > 1)
        {
            printf("No index provided for array identifier %s.\n", ident.c_str());
        }
        $$.place = strdup(ident.c_str());
        $$.arr = false;
    }
    | identifier L_SQUARE_BRACKET expressions R_SQUARE_BRACKET
    {
        std::string temp;
        std::string ident = $1.place;
        if ( funcs.find(ident) == funcs.end() && varTemp.find(ident) == varTemp.end())
        {
            printf("Identifier %s is not declared.\n", ident.c_str());
        }
        else if (arrSize[ident] == 1)
        {
            printf("Provided index for non-array identifier %s.\n", ident.c_str());
        }
        temp.append($1.place);
        temp.append(", ");
        temp.append($3.place);
        $$.code = strdup($3.code);
        $$.place = strdup(temp.c_str());
        $$.arr = true;
    }
    ;

FuncIdent: IDENT
    {
        if (funcs.find($1) != funcs.end()) {
            printf("function name %s is already declared.\n"), $1);
        }
        else
        {
            funcs.insert($1);
        }
        $$.place = strdup($1);
        $$.code = strdup("");
    }
identifiers: identifier 
    {
        $$.place = strdup($1.place);
        $$.code = strdup("");
    }
    | identifier COMMA identifiers 
    {
        std::string temp;
        temp.append($1.place);
        temp.append("|");
        temp.append($3.place);
        $$.place = strdup(temp.c_str());
        $$.code = strdup("");
    }
    ;
identifier: IDENT 
    {
        $$.place = strdup($1);
        $$.code = strdup("");
    }
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

std::string new_temp(){
    std::string t = "t" + std::to_string(tempCount);
    tempCount++;
    return t;
}

std::string new_label(){
    std::string l = "L" + std::to_string(labelCount);
    labelCount++;
    return l;
}
