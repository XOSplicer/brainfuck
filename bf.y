%{
#include <stdlib.h>
#include <stdio.h>
#include "bf_instruction.h"
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern "C" int lines;
extern "C" char* yytext;

void yyerror(const char *s) {
  fprintf (stderr, "Parser error in line %d:\n%s\n", lines, s);
}

#define BF_ARRAY_SIZE 1024
#define BF_MAX_VALUE  255
int bf_array[BF_ARRAY_SIZE];
int bf_array_pointer = 0;

void bf_pinc();
void bf_pdec();
void bf_vinc();
void bf_vdec();
void bf_vset(int i);
void bf_print();
void bf_read();

bf_instruction_t* bf_new_instruction(action_t action, int value, bf_instruction_t* next, bf_instruction_t* sub);

bf_instruction_t* bf_instruction_list;

void bf_execute(bf_instruction_t* start);

%}

%union {
  bf_instruction_t* instr;
}

%token PINC
%token PDEC
%token VINC
%token VDEC
%token PRINT
%token READ
%token OPENW
%token CLOSEW
%token DECINT
%token HEXINT
%token OCTINT

%type <instr> prgrm
%type <instr> cmds
%type <instr> cmd
%type <instr> vset_cmd
%type <instr> while_cmd


%%

prgrm:  cmds       {printf("\tbison: prgrm:\tcmds\n");
                    bf_instruction_list = $1;
                   };

cmds:   cmd cmds  {printf("\tbison: cmds:\tcmd cmds\n");
                    $1->next = $2;
                    $$=$1;
                  }
      | cmd       {printf("\tbison: cmds:\tcmd\n");
                   $1->next = bf_new_instruction(BF_END, 0, NULL, NULL);
                   $$=$1;};

cmd:    while_cmd {printf("\tbison: cmd:\twhile_cmd\n"); $$=$1;}
      | PINC      {printf("\tbison: cmd:\tPINC\n"); $$=bf_new_instruction(BF_PINC, 0, NULL, NULL);}
      | PDEC      {printf("\tbison: cmd:\tPDEC\n"); $$=bf_new_instruction(BF_PDEC, 0, NULL, NULL);}
      | VINC      {printf("\tbison: cmd:\tVINC\n"); $$=bf_new_instruction(BF_VINC, 0, NULL, NULL);}
      | VDEC      {printf("\tbison: cmd:\tVDEC\n"); $$=bf_new_instruction(BF_VDEC, 0, NULL, NULL);}
      | PRINT     {printf("\tbison: cmd:\tPRINT\n"); $$=bf_new_instruction(BF_PRINT, 0, NULL, NULL);}
      | READ      {printf("\tbison: cmd:\tREAD\n"); $$=bf_new_instruction(BF_READ, 0, NULL, NULL);}
      | vset_cmd  {printf("\tbison: cmd:\tvset_cmd\n"); $$=$1;};

vset_cmd:   DECINT    {printf("\tbison: vset_cmd:\tDECINT\n"); $$=bf_new_instruction(BF_VSET, strtol(yytext, NULL, 0), NULL, NULL);}
          | HEXINT    {printf("\tbison: vset_cmd:\tHEXINT\n"); $$=bf_new_instruction(BF_VSET, strtol(yytext, NULL, 0), NULL, NULL);}
          | OCTINT    {printf("\tbison: vset_cmd:\tOCTINT\n"); $$=bf_new_instruction(BF_VSET, strtol(yytext, NULL, 0), NULL, NULL);};

while_cmd:  OPENW cmds CLOSEW {printf("\tbison: while_cmd:\tOPENW cmds CLOSEW\n");
                               $$ = bf_new_instruction(BF_WHILE, 0, NULL, $2);};

%%

int main(int, char**) {
		yyparse();
    //bf_instruction_list = bf_new_instruction(BF_VSET, 42, bf_new_instruction(BF_PRINT, 0, bf_new_instruction(BF_END, 0, NULL, NULL), NULL), NULL);
    printf("##### EXECUTING #####\n");
    bf_execute(bf_instruction_list);
}

void bf_execute(bf_instruction_t* start) {
  bf_instruction_t* instruction_pointer = start;

  while(instruction_pointer && instruction_pointer->action!=BF_END) {
    //what to do with the instruction
    switch (instruction_pointer->action) {
      case BF_PINC:
        bf_array_pointer++;
        if(bf_array_pointer>=BF_ARRAY_SIZE)
          bf_array_pointer = 0;
        break;
      case BF_PDEC:
        bf_array_pointer--;
        if(bf_array_pointer<0)
          bf_array_pointer = BF_ARRAY_SIZE-1;
        break;
      case BF_VINC:
        bf_array[bf_array_pointer]++;
        if(bf_array[bf_array_pointer]>BF_MAX_VALUE)
          bf_array[bf_array_pointer] = 0;
        break;
      case BF_VDEC:
        bf_array[bf_array_pointer]--;
        if(bf_array[bf_array_pointer]<0)
          bf_array[bf_array_pointer] = BF_MAX_VALUE;
        break;
      case BF_VSET:
        bf_array[bf_array_pointer] = instruction_pointer->value;
        break;
      case BF_PRINT:
        //printf("[%d]=%d\n", bf_array_pointer, bf_array[bf_array_pointer]);
        putchar(bf_array[bf_array_pointer]);
        break;
      case BF_READ:
        bf_array[bf_array_pointer] = getchar();
        if(bf_array[bf_array_pointer]>BF_MAX_VALUE) bf_array[bf_array_pointer] = 0;
        break;
      case BF_WHILE:
        while(bf_array[bf_array_pointer]) {
          bf_execute(instruction_pointer->sub);
        }
        break;
      default:
        break;
    }
    //next instruction
    instruction_pointer = instruction_pointer->next;
  }
}

bf_instruction_t* bf_new_instruction(action_t action, int value, bf_instruction_t* next, bf_instruction_t* sub) {
  bf_instruction_t* inst = (bf_instruction_t*)malloc(sizeof(bf_instruction_t));
  inst->action  = action;
  inst->value   = value;
  inst->next    = next;
  inst->sub     = sub;
  return inst;
}
