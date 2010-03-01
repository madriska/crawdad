
module Crawdad

  module Tokens

    def box(width, content)
      [:box, width, content]
    end

    def box?(token)
      token[0] == :box
    end

    def box_content(token)
      token[2]
    end
    
    def glue(width, stretch, shrink)
      [:glue, width, stretch, shrink]
    end

    def glue?(token)
      token[0] == :glue
    end

    def glue_stretch(token)
      token[2]
    end

    def glue_shrink(token)
      token[3]
    end

    def penalty(penalty, width=0, flagged=false)
      [:penalty, width, penalty, flagged]
    end

    def penalty?(token)
      token[0] == :penalty
    end

    def penalty_penalty(token)
      token[2]
    end

    def penalty_flagged?(token)
      token[3]
    end

    def token_width(token)
      token[1]
    end

  end

end
