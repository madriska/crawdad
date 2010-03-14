#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "tokens.h"
#include "paragraph.h"

void inspect_token(token *t) {
  printf("(0x%02lX) ", (unsigned long)t);
  switch(t->box.type){
    case BOX:
      printf("BOX %f\n", t->box.width);
      break;
    case GLUE:
      printf("GLUE %f %f %f\n", t->glue.width, t->glue.stretch, 
        t->glue.shrink);
      break;
    case PENALTY:
      printf("PENALTY %f %f %s\n", t->penalty.penalty, t->penalty.width,
        (t->penalty.flagged ? "F" : "-"));
      break;
    default:
      printf("UNKNOWN %d\n", t->box.type);
  }
}

float calculate_demerits(token *stream[], int old_i, token *new_item, 
                         float r, float flagged_penalty) {
  token *old_item = stream[old_i];
  float d;

  if((new_item->penalty.type == PENALTY) && 
     (new_item->penalty.penalty >= 0)) {
    d = pow(1 + 100*(pow(abs(r), 3) + new_item->penalty.penalty), 2);
  } else if((new_item->penalty.type == PENALTY) &&
          (new_item->penalty.penalty != -INFINITY)) {
    d = pow((1 + 100*(pow(abs(r), 3))), 2) - 
        pow(new_item->penalty.penalty, 2);
  } else {
    d = pow(1 + 100*(pow(abs(r), 3)), 2);
  }

  if(old_item->penalty.type == PENALTY && old_item->penalty.flagged &&
     new_item->penalty.type == PENALTY && new_item->penalty.flagged)
    d += flagged_penalty;

  return d;
}

float adjustment_ratio(float tw, float ty, float tz, 
                       float aw, float ay, float az, 
                       float target_width, token *stream[], int b) {
  float w, y, z; /* w=width y=stretch z=shrink */
  token *item_b = stream[b];

  w = tw - aw; /* Non-adjusted width of the line. */

  /* Add the penalty width (hyphen) if we are breaking at a penalty. */
  if(item_b->penalty.type == PENALTY)
    w += item_b->penalty.width;

  if(w < target_width) {
    y = ty - ay;
    return (y > 0) ? (target_width - w) / y : INFINITY;
  } else if(w > target_width) {
    z = tz - az;
    return (z > 0) ? (target_width - w) / z : INFINITY;
  } else {
    return 0.0;
  }
}

void calculate_widths(token *stream[], float *tw, float *ty, float *tz){
  int i;
  token *p;
  for(i=0; (p = stream[i]); i++) {
    switch(p->box.type) {
      case BOX:
        return;
      case GLUE:
        *tw += p->glue.width;
        *ty += p->glue.stretch;
        *tz += p->glue.shrink;
        break;
      case PENALTY:
        if((p->penalty.penalty == -INFINITY) && (i > 0))
          return;
    }
  }
}

