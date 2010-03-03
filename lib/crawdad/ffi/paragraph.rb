require 'fileutils'

Inliner::C_TO_FFI.update( 'token *  *' => :pointer,
                          'token *'  => :pointer )

module Crawdad

  class Paragraph

    extend Inliner

    inline do |builder|
      builder.include "stdio.h"
      builder.include "stdlib.h"
      builder.include "math.h"

      builder.c_raw <<-'END_C'
        enum token_type { BOX, GLUE, PENALTY };

        struct box {
          enum token_type type;
          double width;
          char * content;
        };

        struct glue {
          enum token_type type;
          double width;
          double stretch;
          double shrink;
        };

        struct penalty {
          enum token_type type;
          double width;
          double penalty;
          int flagged;
        };

        typedef union {
          struct box box;
          struct glue glue;
          struct penalty penalty;
        } token;
      END_C

      builder.c <<-'END_C'
        float _calculate_demerits(token **stream, int old_i, token *new_item, 
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
      END_C

      builder.c <<-'END_C'
        double _adjustment_ratio(double tw, double ty, double tz, 
                                 double aw, double ay, double az, 
                                 double target_width, token **stream, int b) {
          double w, y, z; /* w=width y=stretch z=shrink */
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
      END_C

      builder.c <<-'END_C'
        void _calculate_widths(token **stream, float *tw, float *ty, float *tz){
          token **p;
          for(p=stream; *p; p++) {
            switch((*p)->box.type) {
              case BOX:
                return;
              case GLUE:
                *tw += (*p)->glue.width;
                *ty += (*p)->glue.stretch;
                *tz += (*p)->glue.shrink;
                break;
              case PENALTY:
                if(((*p)->penalty.penalty == -INFINITY) && (p != stream))
                  return;
            }
          }
        }
      END_C

      builder.c <<-'END_C'
        void inspect_token(token *t) {
          printf("(0x%02lX) ", t);
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
      END_C
    end

    def initialize(stream, options={})
      @stream = stream

      # Set up C-accessible array of "token *"s
      @stream_ptr = FFI::MemoryPointer.new(:pointer, stream.length + 1)
      @stream_ptr.write_array_of_pointer(stream)

      @line_widths = options[:line_widths]
      @width = options[:width]
      @flagged_penalty = options[:flagged_penalty] || 3000
      @fitness_penalty = options[:fitness_penalty] || 100
    end

    def calculate_demerits(r, new_item, active_breakpoint)
      self.class._calculate_demerits(@stream_ptr, active_breakpoint.position, 
                                     new_item, r, @flagged_penalty)
    end

    def adjustment_ratio(node_a, b)
      target_width = line_width(node_a.line + 1)

      self.class._adjustment_ratio(@total_width, @total_stretch, @total_shrink,
        node_a.total_width, node_a.total_stretch, node_a.total_shrink,
        target_width, @stream_ptr, b)
    end

    def calculate_widths(b)
      tw = FFI::MemoryPointer.new(:float).put_float32(0, @total_width)
      ty = FFI::MemoryPointer.new(:float).put_float32(0, @total_stretch)
      tz = FFI::MemoryPointer.new(:float).put_float32(0, @total_shrink)

      _calculate_widths(@stream_ptr[b], tw, ty, tz)

      [tw.get_float32(0), ty.get_float32(0), tz.get_float32(0)]
    end

  end
  
end
