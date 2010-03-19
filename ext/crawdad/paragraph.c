#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "tokens.h"
#include "paragraph.h"
#include "breakpoint.h"

#define FLAGGED_PENALTY 3000
#define FITNESS_PENALTY 100

#define GAMMA INFINITY

void inspect_token(token *t) {
  printf("(0x%02lX) ", (unsigned long)t);
  switch(t->box.type){
    case BOX:
      printf("BOX %f \"%s\"\n", t->box.width, t->box.content);
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
                         float r) {
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
    d += FLAGGED_PENALTY;

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

void foreach_legal_breakpoint(token *stream[], float width, float threshold,
    void (*fn)(token **, int, float, float, float, float, float)) {
  float tw=0, ty=0, tz=0;
  int i;
  token *t;

  for(i=0; (t = stream[i]); i++) {
    switch(t->box.type) {
      case BOX:
        tw += t->box.width;
        break;
      case GLUE:
        if(stream[i-1]->box.type == BOX)
          fn(stream, i, tw, ty, tz, width, threshold);
        tw += t->glue.width;
        ty += t->glue.stretch;
        tz += t->glue.shrink;
        break;
      case PENALTY:
        if(t->penalty.penalty != INFINITY)
          fn(stream, i, tw, ty, tz, width, threshold);
        break;
    }
  }
}

int fitness_class(float ratio) {
  if(ratio < -0.5)
    return 0;
  if(ratio < 0.5)
    return 1;
  if(ratio < 1)
    return 2;
  return 3;
}

void concat_new_active_nodes(token *stream[], float total_width, float
    total_stretch, float total_shrink, best_breakpoint best[4], int i,
    breakpoint *active, breakpoint **p_previous_node) {
  float lowest_demerits = INFINITY;
  float tw = total_width, ty = total_stretch, tz = total_shrink;
  int fclass;
  breakpoint *bp;

  for(fclass=0; fclass<4; fclass++)
    if(best[fclass].demerits < lowest_demerits)
      lowest_demerits = best[fclass].demerits;

  calculate_widths(stream + i, &tw, &ty, &tz);

  for(fclass=0; fclass<4; fclass++) {
    if((best[fclass].demerits == INFINITY) ||
        (best[fclass].demerits > lowest_demerits + GAMMA))
      continue;

    /* Create and activate node */
    bp = malloc(sizeof(breakpoint));

    bp->position = i;
    bp->line = best[fclass].bp->line + 1;
    bp->fitness_class = fclass;
    
    bp->total_width = tw;
    bp->total_stretch = ty;
    bp->total_shrink = tz;

    bp->total_demerits = best[fclass].demerits;
    bp->ratio = best[fclass].ratio;
    
    bp->previous = best[fclass].bp;
    bp->link = active;

    if(*p_previous_node)
      (*p_previous_node)->link = bp;
    else
      active_nodes = bp;

    *p_previous_node = bp;
  }
}

void main_loop(token *stream[], int i, float tw, float ty, float tz, 
    float width, float threshold) {
  breakpoint *active, *next_node, *previous_node;
  best_breakpoint best[4];
  int current_line;
  float ratio;
  float demerits;
  int fclass;

  if(active_nodes == NULL) {
    /* TODO: be nicer */
    printf("No feasible solution. Try relaxing threshold.");
    exit(1);
  }

  active = active_nodes;
  previous_node = NULL;
  next_node = NULL;

  while(active) {
    best[0].demerits = INFINITY;
    best[1].demerits = INFINITY;
    best[2].demerits = INFINITY;
    best[3].demerits = INFINITY;

    while(active) {
      current_line = active->line + 1;
      next_node = active->link;

      /* TODO: width can be replaced by a line-specific width for line j */
      ratio = adjustment_ratio(tw, ty, tz, active->total_width,
          active->total_stretch, active->total_shrink, width, 
          stream, i);

      if((ratio < -1) || (is_penalty(stream[i]) && 
            (stream[i]->penalty.penalty == -INFINITY))) {
        /* Remove active node from the list */
        if(previous_node)
          previous_node->link = next_node;
        else
          active_nodes = next_node;
        /* TODO: put active on the passive list or free? */
      } else {
        previous_node = active;
      }

      if((ratio >= -1) && (ratio <= threshold)) {
        demerits = calculate_demerits(stream, active->position, stream[i],
            ratio) + active->total_demerits;
        fclass = fitness_class(ratio);

        /* Penalize consecutive lines more than one fitness class away from
         * each other. */
        if(abs(fclass - active->fitness_class) > 1)
          demerits += FITNESS_PENALTY;

        /* Update high scores if this is a new best. */
        if(demerits < best[fclass].demerits) {
          best[fclass].bp = active;
          best[fclass].demerits = demerits;
          best[fclass].ratio = ratio;
        }
      }

      /* Add nodes to the active list before moving to the next line. */
      active = next_node;
      if(!active)
        break;
      if(active->line >= current_line)
        break;
    }

    /* If we found any best nodes, add them to the active list. */
    concat_new_active_nodes(stream, tw, ty, tz, best, i, active, 
        &previous_node);

    active = next_node;
  }
}

breakpoint *populate_active_nodes(token *stream[], float width, 
    float threshold) {
  breakpoint *bp, *min_node;

  active_nodes = make_starting_breakpoint();
  foreach_legal_breakpoint(stream, width, threshold, main_loop);

  /* Find node with minimum demerits */
  min_node = NULL;
  for(bp = active_nodes; bp; bp = bp->link)
    if(!min_node || (bp->total_demerits < min_node->total_demerits))
      min_node = bp;

  return min_node;
}


