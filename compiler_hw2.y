/*Definition Section*/
%{
    #include <stdio.h>
    #include <math.h>
    #include <string.h>

    extern int linenum;
    extern int yylex();
    extern FILE *yyin;
	void yyerror();
	char msg[256];
	char temp[256];
%}

%union{
	int int_val;
	float float_val;
	char *id_val;
	char *s_val;
}

%token	BOOL CHAR INT FLOAT STRING VOID CLASS
%token	FINAL NEW STATIC
%token  PUBLIC PROTECTED PRIVATE
%token	PLUS MINUS MUL DIV MOD INC DEC
%token	NEWLINE
%token  TRUE FALSE
%token	ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token  LT GT LEQ GEQ EQ NEQ
%token  LAND LOR NOT IF ELSE WHILE FOR
%token  PRINT RETURN READ

%token  <int_val> PINT_LIT
%token	<int_val> NPINT_LIT
%token  <float_val> FLOAT_LIT
%token	<id_val> ID
%token  <s_val> STRING_LIT

%start  program

/*Grammer Section*/
%%

program: stmt stmts
	;

stmts: stmt stmts
	|
	;

stmt: declare
	| classes
	| create_obj
	| compond
	| simple
	| conditional
	| loop
	| return
	| methodInvoc
	| NEWLINE		{	printf("Line %d : %s\n",linenum,msg);
					 	memset(msg, 0, 256);
					}
	| error NEWLINE {yyerrok;memset(msg, 0, 256);}
	;

declare: static type_dec
	;

static: STATIC
	| FINAL
	|
	;

type_dec: BOOL BOOL_list ';'
	| CHAR CHAR_list ';'
	| INT INT_list ';'
	| FLOAT FLOAT_list ';'
	| STRING STRING_list ';'
	;
	
BOOL_list: ID BOOL_init 
	| ID BOOL_init ',' BOOL_list
	| '['']' ID '=' NEW BOOL '[' int_const ']'
	;

BOOL_init: '=' TRUE
	| '=' FALSE
	|
	;

CHAR_list: ID CHAR_init		/*char init字元如何接*/
	| ID CHAR_init ',' CHAR_list
	| '['']' ID '=' NEW CHAR '[' int_const ']'
	;
CHAR_init:
	;

INT_list: ID INT_init
	| ID INT_init ',' INT_list
	| '['']' ID '=' NEW INT '[' int_const ']'
	;

INT_init: '=' PINT_LIT	{sprintf(temp,"%d",$2);
             			 strcat(msg,temp);}
	| '=' NPINT_LIT		{sprintf(temp,"%d",$2);
						 strcat(msg,temp);}
	|
	;

FLOAT_list: ID FLOAT_init
	| ID FLOAT_init ',' FLOAT_list
	| '['']' ID '=' NEW FLOAT '[' int_const ']'
	;

FLOAT_init: '=' FLOAT_LIT {sprintf(temp,"%f",$2);
						   strcat(msg,temp);}
	|
	;

STRING_list: ID STRING_init
	| ID STRING_init ',' STRING_list
	| '['']' ID '=' NEW STRING '[' int_const ']'
	;

STRING_init: '=' STRING_LIT	{sprintf(temp,"%s",$2);
							 strcat(msg,temp);}
	|
	;

int_const: PINT_LIT {	sprintf(temp,"%d",$1);
						strcat(msg,temp);}
	;

classes: CLASS ID '{' fields{printf("hi");} method '}'{printf("hi");}
	;

fields: field
	| field fields
	;

field: declare
	| create_obj
	| NEWLINE {printf("Line %d : %s\n",linenum,msg);memset(msg, 0, 256);}
	;

method: method_mod{printf("hi");} mtype ID '(' arguments ')' compond
	;

method_mod: PUBLIC
	| PROTECTED
	| PRIVATE
	|
	;

mtype: type 
	| VOID
	|
	;

type: BOOL			
	| CHAR
	| INT
	| FLOAT	
	| STRING
	;

arguments: nonemp_arguments
	|
	;

nonemp_arguments: argument
	| argument ',' nonemp_arguments
	;

argument: type ID
	;

create_obj: ID ID '=' NEW ID '(' ')' ';'
	;

compond: '{' stmts '}'
	;

simple: name '=' expression ';'
	| PRINT '(' expression ')' ';'
	| READ '(' name ')' ';'
	| name INC ';'
	| name DEC ';'
	| expression ';'
	|
	;

name: ID
	| ID '.' ID
	;

expression: term
	| expression PLUS term
	| expression MINUS term
	;

term: factor
	| factor MUL term
	| factor DIV term
	;

factor: ID
	| '(' expression ')'
	| prefixop ID
	| ID postfixop
	| methodInvoc
	| PINT_LIT    {sprintf(temp,"%d",$1);
				   strcat(msg,temp);} 
	| NPINT_LIT   {sprintf(temp,"%d",$1);
				   strcat(msg,temp);}
	| FLOAT_LIT   {sprintf(temp,"%f",$1);
				   strcat(msg,temp);}
	;

prefixop: INC
	| DEC
	| PLUS
	| MINUS	
	;

postfixop: INC
	| DEC
	;

methodInvoc: name '(' invoc_exp ')'

invoc_exp: expression
	| expression ',' invoc_exp
	;

conditional: IF '(' bool_expr ')' simple_compond else_expr
	;

bool_expr: expression infixop expression
	;

infixop: EQ
	| NEQ
	| LT
	| GT
	| LEQ
	| GEQ
	;

simple_compond: simple
	| compond
	;

else_expr: ELSE simple_compond
	;

loop: WHILE '(' bool_expr ')' simple_compond
	| FOR '(' forinit ';' bool_expr ';' forupdate ')' simple_compond
	;

forinit: int_dec ID '=' expression
	| int_dec ID '=' expression ',' forinit
	;

int_dec: INT
	|
	;

forupdate: ID INC
	| ID DEC
	;

return: RETURN expression ';'
	;



/*C Code Section*/
%%
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }

    yyparse();
	printf("total line:%d\n",linenum+1);
    fclose(yyin);
    return 0;
}

void yyerror (char const *s)
{
	printf("%s at line %d\n",s,linenum+1);
}

