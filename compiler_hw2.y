/*Definition Section*/
%{
    #include <stdio.h>
    #include <math.h>
    #include <string.h>

    extern int linenum;
	extern int charnum;
	extern int befchar;
    extern int yylex();
    extern FILE *yyin;
	extern void create();
	extern char* yytext;

	int scope = 0;
	int isdec = 0;
	int duplicate = 0;
	int boolexperr = 0;
	int errnum;
	char errword;
	void yyerror();
	char msg[256];
	char temp[256];
	char dupl[256];
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
	| compond
	| simple
	| conditional
	| loop
	| return
	| methodInvoc
	| NEWLINE			{ printf("Line %d : %s\n",linenum,msg);
					 	  memset(msg, 0, 256);
						  if(duplicate==1){
						  	printf("%s",dupl);
							duplicate=0;
						  }
						  if(boolexperr==1){
						  	printf("Line %d, 1st char: %d, a syntax error at \"%c\"\n",linenum,errnum,errword);
						  	boolexperr=0;
						  }
						}
	| error NEWLINE 	{ yyerrok;
						  memset(msg, 0, 256); }
	;

declare: static type id_list {isdec=1;}
	;

static: STATIC
	| FINAL
	| PUBLIC
	| PROTECTED
	| PRIVATE
	|
	;

id_list: BOOL_list ';'
	| CHAR_list ';'
	| INT_list ';'
	| FLOAT_list ';'
	| STRING_list ';'
	| ID'(' arguments ')' isline compond
	| ID'('')' isline compond
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
	| '=' expression
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

isline: 
	| NEWLINE		{printf("Line %d : %s\n",linenum,msg);
					 memset(msg, 0, 256);}
	;

classes: CLASS ID isline '{' {scope++;} fields '}'{scope--;}

fields: field
	| field fields
	;

field: declare
	| create_obj
	| classes
	| NEWLINE			{   printf("Line %d : %s\n",linenum,msg);
                        	memset(msg, 0, 256);
							if(duplicate==1){
								printf("%s",dupl);
								duplicate=0;
							}
						}
	| error NEWLINE		{	yyerrok;memset(msg, 0, 256);}
	;

type: BOOL			
	| CHAR
	| INT
	| FLOAT	
	| STRING
	| VOID
	;

arguments: argument
	| argument ',' arguments
	;

argument: type ID
	;

create_obj: {isdec=0;}ID ID '=' NEW ID '(' ')' ';'
	;

compond: '{' {scope++;} stmts '}' {scope++;}
	;

simple:name '=' expression ';'
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

factor: ID iscreate
	| ID '[' number ']'
	| '(' expression ')'
	| prefixop ID
	| ID postfixop
	| ID '[' number ']'postfixop
	| methodInvoc
	| PINT_LIT    {sprintf(temp,"%d",$1);
				   strcat(msg,temp);} 
	  ispostop
	| NPINT_LIT   {sprintf(temp,"%d",$1);
				   strcat(msg,temp);}
	| FLOAT_LIT   {sprintf(temp,"%f",$1);
				   strcat(msg,temp);}
	| STRING_LIT  {sprintf(temp,"%s",$1);
				   strcat(msg,temp);}
	;

iscreate: ID '=' NEW ID '(' ')'
	|
	;

prefixop: INC
	| DEC
	| PLUS
	| MINUS	
	;

postfixop: INC
	| DEC
	;

ispostop: postfixop
	|
	;

methodInvoc: name '(' invoc_exp ')'

invoc_exp: expression
	| expression ',' invoc_exp
	;

conditional: IF '(' bool_expr ')' simple_compond else_expr
	;

bool_expr: {isdec=0;}expression infixop expression
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
	|
	;

loop: WHILE '('{boolexperr=1;} bool_expr ')'{boolexperr=0;} simple_compond
	| FOR '('{isdec=0;} forinit ';' bool_expr ';' forupdate ')' simple_compond
	| error ')'
	;

forinit: int_dec ID isarr '=' expression
	| int_dec ID isarr '=' expression ',' forinit
	
isarr: '[' number ']'
	|
	;

int_dec: INT
	|
	;

forupdate: ID INC
	| ID DEC
	| ID '[' number ']' INC
	| ID '[' number ']' DEC
	;

return: RETURN expression ';'
	;

number: PINT_LIT	{sprintf(temp,"%d",$1);
                     strcat(msg,temp);}
	| NPINT_LIT		{sprintf(temp,"%d",$1);
                     strcat(msg,temp);}
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
	create();
    yyparse();
    fclose(yyin);
    return 0;
}

void yyerror (char const *s)
{	
	errword=yytext[0];
	errnum=charnum+1;
	if(boolexperr==0){
		printf("Line %d : %s\n",linenum+1,msg);
		if((int)yytext[0]!=10)
			printf("Line %d, 1st char: %d, a syntax error at \"%s\"\n",linenum+1,charnum+1,yytext);
		else
			printf("Line %d, 1st char: %d, a syntax error in lacking of semicolon\n",linenum+1,befchar+2);
	}
	duplicate=0;
}

