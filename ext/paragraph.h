void inspect_token(token *t);

float calculate_demerits(token *stream[], int old_i, token *new_item, 
												 float r, float flagged_penalty);

float adjustment_ratio(float tw, float ty, float tz, 
                       float aw, float ay, float az, 
                       float target_width, token *stream[], int b);

void calculate_widths(token *stream[], float *tw, float *ty, float *tz);

void foreach_legal_breakpoint(token *stream[], 
    void (*fn)(float, float, float));

