#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "tokens.h"

int token_type(token *t) {
	return t->box.type;
}

int is_box(token *t) {
	return (t->box.type == BOX);
}

int is_penalty(token *t) {
  return (t->penalty.type == PENALTY);
}

int is_glue(token *t) {
	return (t->glue.type == GLUE);
}

