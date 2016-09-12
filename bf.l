%{
#include "bf_instruction.h"
#include "bf.tab.h"
#define YY_DECL extern "C" int yylex()
int lines = 1;
%}

PINC    (>)
PDEC    (<)
VINC    (\+)
VDEC    (-)
PRINT   (\.)
READ    (,)
OPENW   (\[)
CLOSEW  (\])
COMMENT (#.*\n)
ENDL    (\n)
DECINT  ([1-9][0-9]*)
HEXINT  (0[xX][0-9]*)
OCTINT  (0[0-9]*)

%%

{PINC}    {printf("flex: PINC\n"); return PINC;}
{PDEC}    {printf("flex: PDEC\n"); return PDEC;}
{VINC}    {printf("flex: VINC\n"); return VINC;}
{VDEC}    {printf("flex: VDEC\n"); return VDEC;}
{PRINT}   {printf("flex: PRINT\n"); return PRINT;}
{READ}    {printf("flex: READ\n"); return READ;}
{OPENW}   {printf("flex: OPENW\n"); return OPENW;}
{CLOSEW}  {printf("flex: CLOSEW\n"); return CLOSEW;}
{COMMENT} {printf("flex: COMMENT\n");}
{ENDL}    {printf("flex: ENDL\n"); ++lines;}
{DECINT}  {printf("flex: DECINT\n"); return DECINT;}
{HEXINT}  {printf("flex: HEXINT\n"); return HEXINT;}
{OCTINT}  {printf("flex: OCTINT\n"); return OCTINT;}
