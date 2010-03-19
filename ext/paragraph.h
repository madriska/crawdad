#ifndef _PARAGRAPH_H_
#define _PARAGRAPH_H_

#include "breakpoint.h"

void inspect_token(token *t);

float calculate_demerits(token *stream[], int old_i, token *new_item, 
												 float r);

float adjustment_ratio(float tw, float ty, float tz, 
                       float aw, float ay, float az, 
                       float target_width, token *stream[], int b);

void calculate_widths(token *stream[], float *tw, float *ty, float *tz);

void foreach_legal_breakpoint(token *stream[], float width, float threshold,
    void (*fn)(token **, int, float, float, float, float, float));

int fitness_class(float ratio);

void main_loop(token *stream[], int i, float tw, float ty, float tz, 
    float width, float threshold);

breakpoint *populate_active_nodes(token *stream[], float width, 
								float threshold);

#endif

