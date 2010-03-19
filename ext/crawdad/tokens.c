#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "tokens.h"

struct box *make_box(float width, char *content) {
	int len;
  struct box *t;
	
	t = malloc(sizeof(struct box));
  t->type = BOX;
  t->width = width;

	len = strlen(content);
	t->content = malloc(len+1);
	strncpy(t->content, content, len);
	t->content[len] = '\0';

  return t;
}

struct glue *make_glue(float width, float stretch, float shrink) {
  struct glue *t = malloc(sizeof(struct glue));
  t->type = GLUE;
  t->width = width;
  t->stretch = stretch;
  t->shrink = shrink;
  return t;
}

struct penalty *make_penalty(float width, float penalty, int flagged) {
  struct penalty *t = malloc(sizeof(struct penalty)); 
  t->type = PENALTY;
  t->width = width;
  t->penalty = penalty;
  t->flagged = flagged;
  return t;
}

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

