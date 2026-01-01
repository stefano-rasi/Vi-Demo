require 'opal'

require_relative 'html'

class View
    def self.draw(&block)
        if block_given?
            @draw_block = block
        else
            @draw_block
        end
    end

    def element
        if !@element
            @element = instance_eval(&self.class.draw)
        end

        @element
    end

    def draw()
        if @element
            element = instance_eval(&self.class.draw)

            @element.replaceWith(element)

            @element = element
        else
            @element = instance_eval(&self.class.draw)
        end
    end
end