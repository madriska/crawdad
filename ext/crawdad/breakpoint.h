#ifndef _BREAKPOINT_H_
#define _BREAKPOINT_H_

typedef struct breakpoint {
  int position;
  int line;
  int fitness_class;

  float total_width;
  float total_stretch;
  float total_shrink;
  float total_demerits;

  float ratio;

  struct breakpoint *previous;
  struct breakpoint *link;
} breakpoint;

struct breakpoint *active_nodes;

breakpoint *make_starting_breakpoint() {
  breakpoint *bp;
  
  bp = malloc(sizeof(breakpoint));

  bp->position = 0;
  bp->line = 0;
  bp->fitness_class = 1;
  
  bp->total_width = 0.0;
  bp->total_stretch = 0.0;
  bp->total_shrink = 0.0;
  bp->total_demerits = 0.0;
  
  bp->ratio = 0.0;
  
  bp->previous = NULL;
  bp->link = NULL;

  return bp;
}

/* Holds information about the best breakpoint found so far for a particular
 * fitness class. */
typedef struct best_breakpoint {
  breakpoint *bp;
  float demerits;
  float ratio;
} best_breakpoint;

#endif

