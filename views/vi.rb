require 'lib/view/html'
require 'lib/view/view'

require 'lib/view/window'
require 'lib/view/document'

class ViView < View
    draw do
        HTML.div 'vi-view', "#{@mode}-mode" do
            HTML.div 'lines' do
                y = 0

                @lines.each do |line|
                    HTML.div 'line' do
                        x = 0

                        if line.empty?
                            HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                if x == @x && y == @y
                                    @cursor = element
                                end
                            end
                        else
                            line.each do |character|
                                HTML.div 'character', ('cursor' if x == @x && y == @y) do |element|
                                    _text character

                                    if x == @x && y == @y
                                        @cursor = element
                                    end
                                end

                                x += 1
                            end

                            if y == @y && @x == x
                                HTML.div 'character cursor last' do |element|
                                    @cursor = element
                                end
                            end
                        end
                    end

                    y += 1
                end
            end

            HTML.div 'status-bar' do
                if @mode == :command
                    HTML.div 'command' do
                        _text ":#{@command}"
                    end
                else
                    HTML.div 'mode' do
                        _text "--#{@mode}--"
                    end
                end

                if @pending || @multiplier
                    HTML.div 'pending' do |html|
                        _text "#{@pending}#{@multiplier}"
                    end
                end
            end
        end
    end

    def initialize(text)
        @x = 0
        @y = 0

        @mode = :normal

        if text
            lines = text.split("\n")

            if lines.is_a? Array
                @lines = lines.map { |line| line.split('') }
            else
                @lines = [lines.split('')]
            end
        else
            @lines = [[]]
        end

        Window.addEventListener('keydown', &method(:on_keydown))
    end

    def text
        @lines.map { |line| line.join('') }.join("\n")
    end

    def scroll()
        @cursor.scrollIntoView({block: :nearest})
    end

    def normal(event)
        key = event.key

        if @multiplier
            multiplier = @multiplier
        else
            multiplier = 1
        end

        case key
        when ':'
            @mode = :command
        when '$'
            x = @lines[@y].length-1

            case @pending
            when 'c', 'd'
                (x - @x + 1).times { @lines[@y].delete_at(@x) }

                @x -= 1 if @x > 0
            else
                @x = x
            end

            @mode = :insert if @pending == 'c'
        when '0'
            @x = 0
        when '1'..'9'
            pending = @pending

            if @multiplier
                new_multiplier = (@multiplier.to_s + key).to_i
            else
                new_multiplier = key.to_i
            end
        when 'a'
            @x += 1 if !@lines[@y].empty?

            @mode = :insert
        when 'c'
            pending = 'c'
        when 'd'
            case @pending
            when 'd'
                @lines.delete_at(@y)

                @x = 0
                @y -= 1 if @y == @lines.length && @y > 0

                @lines = [[]] if @lines.empty?
            else
                pending = 'd'
            end
        when 'j'
            y = @y + [multiplier, @lines.length-1 - @y].min

            case @pending
            when 'd'
                (y - @y + 1).times { @lines.delete_at(@y) }

                @x = 0
                @y -= 1 if @y == @lines.length && @y > 0

                @lines = [[]] if @lines.empty?
            else
                @y = y

                @x = [0, [@x, @lines[@y].length-1].min].max
            end
        when 'k'
            @y -= [multiplier, @y].min

            @x = [0, [@x, @lines[@y].length-1].min].max
        when 'h'
            @x -= [multiplier, @x].min

            @mode = :insert if @pending == 'c'
        when 'l'
            @x += [0, [multiplier, @lines[@y].length-1 - @x].min].max

            @mode = :insert if @pending == 'c'
        when 'i'
            @mode = :insert
        when 'o'
            @lines.insert(@y + 1, [] * multiplier)

            @x = 0
            @y += 1

            @mode = :insert
        when 'r'
            @mode = :replace
        when 's'
            @lines[@y].delete_at(@x)

            @mode = :insert
        when 'y'
            case @pending
            when 'y'
                @yank = @lines[@y]
            else
                pending = 'y'
            end
        when 'G'
            @x = 0
            @y = @lines.length-1
        when 'J'
            @lines[@y] += @lines[@y + 1]

            @lines.delete_at(@y + 1)
        when 'O'
            @lines.insert(@y, [] * multiplier)

            @x = 0

            @mode = :insert
        when :Escape
            pending = nil
        else
            if key.length != 1
                pending = @pending

                new_multiplier = @multiplier
            end
        end

        @pending = pending

        @multiplier = new_multiplier
    end

    def insert(event)
        key = event.key

        case key
        when :Enter
            @lines.insert(@y + 1, [])

            @x = 0
            @y += 1
        when :Escape
            @x -= 1 if @x > 0

            @mode = :normal
        when :Backspace
            @lines[@y].delete_at(@x - 1)

            @x -= 1 if @x > 0
        else
            if key.length == 1
                @lines[@y].insert(@x, key)

                @x += 1
            end
        end
    end

    def replace(event)
        key = event.key

        case key
        when :Escape
            @mode = :normal
        else
            if key.length == 1
                @lines[@y][@x] = key

                @mode = :normal
            end
        end
    end

    def command(event)
        key = event.key

        case key
        when :Enter
            @command = nil

            @mode = :normal
        when :Escape
            @command = nil

            @mode = :normal
        else
            if key.length == 1
                @command = '' if !@command

                @command += key
            end
        end
    end

    def on_keydown(event)
        event = Native(event)

        mode = @mode

        case mode
        when :normal
            normal(event)
        when :insert
            insert(event)
        when :replace
            replace(event)
        when :command
            command(event)
        end

        draw
        scroll
    end
end

Window.addEventListener('load') do
    vi = ViView.new("line 1\nline 2\nline 3\nline 4")

    Document.body.appendChild(vi.element)
end