unless [].respond_to?(:find_index)
  module Enumerable
    def find_index(needle=nil, &b)
      each_with_index do |hay, i|
        if b ? b[hay] : needle == hay
          return i
        end
      end
      nil
    end
  end
end
