%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"	/* header file generated by bison */
	
	#define MAX	256

	extern char msg[256];
	extern char dupl[256];
	extern int isdec;
	extern int duplicate;
	extern int scope;

	int linenum = 0;
	int charnum = 0;
	int befchar;
	char temp[256];

	void nlinecount(char *word);
	void create();
	int lookup(char *word,int scope);
	int insert(char *word,int scope);
	void dump();
	int hash(char *word);
%}

/* Define regular expression label */
digit           [0-9]
letter			[A-Za-z]
inumber			(-?{digit}+)
fnumber         (-?({digit}+|{digit}*\.{digit}+)([eE][+-]?{digit}+)?f?)
id              ([\_\$]|{letter})+([\_\$]|{letter}|{digit})*
inv_id			([\^\#]|{digit})+([\_\$]|{letter}|{digit})*
ws				[ \t]
inv_str         \"[\"]+\"|\'[^(\'|\n)]*\'|\"[^(\"|\n)]*|\"[^(\"|\n)]*\\\"
string          \"[^\n]*\"
comments        "/*"((\*+[^/*])|([^*]))*\**"*/"
comment         ([/]{2}.*)\n


/* Rule Section*/
%%
<<EOF>>     	{linenum++;yyterminate();}
"+" 			{strcat(msg,"+");charnum+=yyleng;return PLUS;}			
"-"				{strcat(msg,"-");charnum+=yyleng;return MINUS;}
"*" 			{strcat(msg,"*");charnum+=yyleng;return MUL;}
"/"				{strcat(msg,"/");charnum+=yyleng;return DIV;}
"%"				{strcat(msg,"%");charnum+=yyleng;return MOD;}
"++" 			{strcat(msg,"++");charnum+=yyleng;return INC;}
"--" 			{strcat(msg,"--");charnum+=yyleng;return DEC;}

"=" 			{strcat(msg,"=");charnum+=yyleng;return '=';}
"+="			{strcat(msg,"+=");charnum+=yyleng;return ADD_ASSIGN;}
"-="			{strcat(msg,"-=");charnum+=yyleng;return SUB_ASSIGN;}
"*="			{strcat(msg,"*=");charnum+=yyleng;return MUL_ASSIGN;}
"/="			{strcat(msg,"/=");charnum+=yyleng;return DIV_ASSIGN;}
"%="			{strcat(msg,"%=");charnum+=yyleng;return MOD_ASSIGN;}

"<"				{strcat(msg,"<");charnum+=yyleng;return LT;}
">"				{strcat(msg,">");charnum+=yyleng;return GT;}
"<=" 			{strcat(msg,"<=");charnum+=yyleng;return LEQ;}
">=" 			{strcat(msg,">=");charnum+=yyleng;return GEQ;}
"==" 			{strcat(msg,"==");charnum+=yyleng;return EQ;}
"!=" 			{strcat(msg,"!=");charnum+=yyleng;return NEQ;}

"&&" 			{strcat(msg,"&&");charnum+=yyleng;return LAND;}
"||" 			{strcat(msg,"||");charnum+=yyleng;return LOR;}
"!"				{strcat(msg,"!");charnum+=yyleng;return NOT;}

"("				{strcat(msg,"(");charnum+=yyleng;return '(';}
")"				{strcat(msg,")");charnum+=yyleng;return ')';}
"["				{strcat(msg,"[");charnum+=yyleng;return '[';}
"]"				{strcat(msg,"]");charnum+=yyleng;return ']';}
"{"				{strcat(msg,"{");charnum+=yyleng;return '{';}	
"}"				{strcat(msg,"}");charnum+=yyleng;return '}';}

"."				{strcat(msg,".");charnum+=yyleng;return '.';}
","				{strcat(msg,",");charnum+=yyleng;return ',';}
";"				{strcat(msg,";");charnum+=yyleng;return ';';}
":"				{strcat(msg,":");charnum+=yyleng;return ':';}
"\n"            {linenum++;befchar=charnum;charnum=0;return NEWLINE;}

boolean			{strcat(msg,"boolean");charnum+=yyleng;return BOOL;}
char			{strcat(msg,"char");charnum+=yyleng;return CHAR;}
int				{strcat(msg,"int");charnum+=yyleng;return INT;}
float			{strcat(msg,"float");charnum+=yyleng;return FLOAT;}
string			{strcat(msg,"string");charnum+=yyleng;return STRING;}
void			{strcat(msg,"void");charnum+=yyleng;return VOID;}
class			{strcat(msg,"class");charnum+=yyleng;return CLASS;}

final			{strcat(msg,"final");charnum+=yyleng;return FINAL;}
new				{strcat(msg,"new");charnum+=yyleng;return NEW;}
static			{strcat(msg,"static");charnum+=yyleng;return STATIC;}
main			{strcat(msg,"main");charnum+=yyleng;return MAIN;}

public			{strcat(msg,"public");charnum+=yyleng;return PUBLIC;}
protected		{strcat(msg,"protected");charnum+=yyleng;return PROTECTED;}
private			{strcat(msg,"private");charnum+=yyleng;return PRIVATE;}

true			{strcat(msg,"true");charnum+=yyleng;return TRUE;}
false			{strcat(msg,"false");charnum+=yyleng;return FALSE;}

if				{strcat(msg,"if");charnum+=yyleng;return IF;}
else			{strcat(msg,"else");charnum+=yyleng;return ELSE;}
while			{strcat(msg,"while");charnum+=yyleng;return WHILE;}
for				{strcat(msg,"for");charnum+=yyleng;return FOR;}

print			{strcat(msg,"print");charnum+=yyleng;return PRINT;}
return			{strcat(msg,"return");charnum+=yyleng;return RETURN;}
read			{strcat(msg,"read");charnum+=yyleng;return READ;}

break |
byte |
case |
catch |
continue |
default |
do |
double |
extend |
finally |
implements |
long |
short |
switch |
this |
try 			{;}
{inumber}       {sscanf(yytext,"%d",&yylval.int_val);charnum+=yyleng;
				 if(yylval.int_val>0) return PINT_LIT;
				 else return NPINT_LIT;
				}
{fnumber}       {sscanf(yytext,"%f",&yylval.float_val);charnum+=yyleng;return FLOAT_LIT;}
{id}			{sprintf(temp,"%s",yytext);strcat(msg,temp);charnum+=yyleng;
				 yylval.id_val = strdup(yytext);
				 insert(yytext,scope);
				 return ID;}
{inv_id}		{printf("Line:%d,1st char:%d,\"%s\" is a \"invalid identifier\"\n",linenum+1,charnum+1,yytext);}
{ws}			{sprintf(temp,"%s",yytext);strcat(msg,temp);charnum+=yyleng;}
{inv_str}       {printf("Line:%d,1st char:%d,%s is a \"invalid string\"\n",linenum+1,charnum+1,yytext);}
{string}        {yylval.s_val = strdup(yytext);charnum+=yyleng;return STRING_LIT;;}
{comment}       {linenum++;charnum=0;
				 printf("Line %d : %s%s",linenum,msg,yytext);
				 memset(msg,0,256);}
{comments}		{nlinecount(yytext);}
.				{;}
%%
int yywrap(void)
{
    return 1;
}

void nlinecount(char* word){
	int count=0;
	for(int i=0;i<yyleng;i++){
		count++;
		if((int)word[i]==10){
			printf("Line %d : %s\n",linenum+1,msg);
			linenum++;
			count=0;
			memset(msg,0,256);
		}
		else{
			sprintf(temp,"%c",word[i]);
			strcat(msg,temp);
		}
	}
	charnum += count;
}

struct id_data{
	char* id_name;
	struct	id_data *next;
};

struct id_data **s;		//for symbol table

void create(){
	s = (struct id_data**)malloc(sizeof(struct id_data*)*20);
	for(int i=0;i<20;i++)
		s[i]=(struct id_data*)malloc(sizeof(struct id_data) * MAX);
	for(int i=0;i<20;i++)
		for(int j=0;j<MAX;j++)
			s[i][j].next = NULL;
}

int lookup(char *word,int scope){
	int hashnum = hash(word);
	struct id_data *p = &s[scope][hashnum];
	p = p->next;
	while(p){
		if(strcmp(p->id_name,word)==0) return hashnum;
		p = p->next;
	}
	return -1;
}

int insert(char *word,int scope){
	int hashnum = hash(word);
	struct id_data *node;
	if(lookup(word,scope)>=0){
		if(isdec==1){
			sprintf(dupl,"\'%s\' is a duplicate identifier\n",word);
			duplicate=1;
			isdec=0;
		}
		return -1;
	}
	node = (struct id_data *) malloc(sizeof(struct id_data));
	if(s[scope][hashnum].next==NULL)
		node->next = NULL;
	else
		node->next = s[scope][hashnum].next;
	s[scope][hashnum].next = node;
	node->id_name = (char *) malloc(strlen(word)+1);
	strcpy(node->id_name,word);
	return hashnum;
}

void dump(){
	printf("The symbol table contains:\n");
	for(int i=0;i<20;i++){
		printf("SCOPE %d :\n",i);
		for(int j=0;j<MAX;j++){
			int count=0;
			struct id_data *p =  &s[i][j];
			p = p->next;
			if(p){
				printf("	index %d:\n",j);
				while(p){
					printf("		%-10s",p->id_name);
					count++;
					if((count%5)==0) printf("\n");
					p = p->next;
				}
				if((count%5)!=0) printf("\n");
			}
		}
	}
}

int hash(char *word){
	int sum = 0;
	int hashnum;
	for(int i=0;i<strlen(word);i++)
		sum += (int)word[i];
	hashnum = sum % MAX;
	return hashnum;
}
