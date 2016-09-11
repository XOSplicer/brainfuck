#ifndef BF_INSTRUCTION_H
#define BF_INSTRUCTION_H

typedef enum {BF_PINC, BF_PDEC, BF_VINC, BF_VDEC, BF_VSET, BF_PRINT, BF_READ, BF_WHILE, BF_END} action_t;

typedef struct bf_instruction_t {
  action_t action;
  int value;
  bf_instruction_t* next;
  bf_instruction_t* sub;
} bf_instruction_t;

#endif
