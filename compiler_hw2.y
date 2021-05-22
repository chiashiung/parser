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
	int pint_val;
	int npint_val;
	float float_val;
	char *id_val;
	char *s_val;
}

%token	BOOL CHAR INT FLOAT STRING VOID
%token	FINAL NEW STATIC
%token  PUBLIC PROTECTED PRIVATE
%token	PLUS MINUS MUL DIV MOD INC DEC
%token	NEWLINE
%token  TRUE FALSE
%token	ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token  LT GT LEQ GEQ EQ NEQ
%token  LAND LOR NOT IF ELSE
%token  PRINT

%token  <pint_val> PINT_LIT
%token	<npint_val> NPINT_LIT
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
	| compond
	| simple
	| conditional
	/*| loop
	| return
	| method_call*/
	| NEWLINE		{	printf("Line %d : %s\n",linenum,msg);
					 	memset(msg, 0, 256);
					}
	| error NEWLINE {yyerrok;}
	;

declare: static type_dec
	;

static: STATIC	{strcat(msg,"static");}
	| FINAL		{strcat(msg,"final");}
	|
	;

type_dec: BOOL {strcat(msg,"boolean");} BOOL_list ';' {strcat(msg,";");}
	| CHAR {strcat(msg,"char");} CHAR_list ';' {strcat(msg,";");}
	| INT {strcat(msg,"int");}	INT_list ';' {strcat(msg,";");}
	| FLOAT {strcat(msg,"float");} FLOAT_list ';' {strcat(msg,";");}
	| STRING {strcat(msg,"string");} STRING_list ';' {strcat(msg,";");}
	;
	
BOOL_list: ID_term  BOOL_init 
	| ID_term BOOL_init ','{strcat(msg,",");} BOOL_list
	| '['']' {strcat(msg,"[]");} ID_term '=' {strcat(msg,"=");} NEW {strcat(msg,"new");} BOOL '[' {strcat(msg,"[");} int_const ']' {strcat(msg,"]");}
	;

BOOL_init: '=' {strcat(msg,"=");} TRUE {strcat(msg,"true");}
	| '=' {strcat(msg,"=");} FALSE	{strcat(msg,"false");}
	|
	;

CHAR_list: ID_term CHAR_init		/*char init字元如何接*/
	| ID_term CHAR_init ',' {strcat(msg,",");} CHAR_list
	| '['']' {strcat(msg,"[]");} ID_term '=' {strcat(msg,"=");} NEW {strcat(msg,"new");} CHAR '[' {strcat(msg,"[");} int_const ']' {strcat(msg,"]");}
	;
CHAR_init:
	;

INT_list: ID_term INT_init
	| ID_term INT_init ',' {strcat(msg,",");} INT_list
	| '['']' {strcat(msg,"[]");} ID_term '=' {strcat(msg,"=");} NEW {strcat(msg,"new");} INT '[' {strcat(msg,"[");} int_const ']' {strcat(msg,"]");}
	;

INT_init: '=' PINT_LIT	{sprintf(temp," = %d",$2);
             			 strcat(msg,temp);}
	| '=' NPINT_LIT		{sprintf(temp," = %d",$2);
						 strcat(msg,temp);}
	|
	;

FLOAT_list: ID_term FLOAT_init
	| ID_term FLOAT_init ',' {strcat(msg,",");} FLOAT_list
	| '['']' {strcat(msg,"[]");} ID_term '=' {strcat(msg,"=");} NEW {strcat(msg,"new");} FLOAT '[' {strcat(msg,"[");} int_const ']' {strcat(msg,"]");}
	;

FLOAT_init: '=' FLOAT_LIT {sprintf(temp," = %f",$2);
						   strcat(msg,temp);}
	|
	;

STRING_list: ID_term STRING_init
	| ID_term STRING_init ',' {strcat(msg,",");} STRING_list
	| '['']' {strcat(msg,"[]");} ID_term '=' {strcat(msg,"=");} NEW {strcat(msg,"new");} STRING '[' {strcat(msg,"[");} int_const ']' {strcat(msg,"]");}
	;

STRING_init: '=' STRING_LIT	{sprintf(temp," = %s",$2);
							 strcat(msg,temp);}
	|
	;

ID_term: ID {	sprintf(temp,"%s",$1);
				strcat(msg,temp);}
    ;

int_const: PINT_LIT {	sprintf(temp,"%d",$1);
						strcat(msg,temp);}
	;

classes: method
	;
	
method: method_mod mtype ID_term '(' {strcat(msg,"(");} arguments ')' {strcat(msg,")");} '{' {strcat(msg,"{");} compond '}' {strcat(msg,"}");}
	;

method_mod: PUBLIC	{strcat(msg,"public");}
	| PROTECTED		{strcat(msg,"protected");}
	| PRIVATE		{strcat(msg,"private");}
	;

mtype: type 
	| VOID			{strcat(msg,"void");}
	;

type: BOOL			{strcat(msg,"bool");}
	| CHAR			{strcat(msg,"char");}
	| INT			{strcat(msg,"int");}
	| FLOAT			{strcat(msg,"float");}
	| STRING		{strcat(msg,"string");}
	;

arguments: nonemp_arguments
	|
	;

nonemp_arguments: argument
	| argument ',' {strcat(msg,",");} nonemp_arguments
	;

argument: type ID_term
	;


compond: '{' {strcat(msg,"{");} stmts '}' {strcat(msg,"}");}
	;

simple: name expression ';'
	| PRINT '(' expression ')' ';'
	| name INC ';'
	| name DEC ';'
	| expression ';'
	;

name: ID_term
	| ID_term '.' ID_term
	;

expression: term
	| expression '+' term
	| expression '-' term
	;

term: factor 
	| factor MUL term
	| factor DIV term
	;

factor: ID_term
	| '(' expression ')'
	| prefixop ID_term
	| ID_term postfixop
	| methodInvoc
	;

prefixop: INC
	| DEC
	| PLUS
	| MINUS
	;

postfixop: INC
	| DEC
	;

methodInvoc: name'('invoc_exp')'

invoc_exp: expression
	| expression ',' invoc_exp
	;

conditional: IF {strcat(msg,"if");} '(' {strcat(msg,"(");} bool_expr ')' {strcat(msg,")");} simple_compond else_expr
	;

bool_expr: 
	;

simple_compond: simple
	| compond
	;

else_expr: ELSE {strcat(msg,"else");} simple_compond
	;

/*loop:
	;

return:
	;

method_call:
	;*/


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
	memset(msg, 0, 256);
}

