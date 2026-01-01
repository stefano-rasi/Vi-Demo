require 'opal'
require 'native'

require_relative 'view'
require_relative 'document'

module HTML
    def HTML.method_missing(name, *args, **kwargs, &block)
        element = Document.createElement(name)

        if !kwargs.empty?
            kwargs.each do |key, value|
                case key
                when 'text'
                    element.textContent = value
                when 'title'
                    element.title = value
                when 'value'
                    element.value = value
                when 'disabled'
                    element.disabled = value
                when 'required'
                    element.required = value
                when 'selected'
                    element.selected = value
                when 'placeholder'
                    element.placeholder = value
                end
            end
        end

        if !args.empty?
            element.className = args.compact.join(' ')
        end

        parent = @element

        if parent
            parent.appendChild(element)
        end

        @element = element

        if block_given?
            block.call(element)
        end

        @element = parent

        element
    end

    def HTML.element
        @element
    end
end

module Kernel
    alias_method :old_method_missing, :method_missing

    def method_missing(name, *args, &block)
        if HTML.element
            if /^[A-Z]/.match(name)
                if self.class.const_defined?(name)
                    klass = self.class.const_get(name)

                    if klass < View
                        view_class = self.class.const_get(name)

                        view = view_class.new(*args, &block)

                        HTML.element.appendChild(view.element)

                        if block_given?
                            block.call(view)
                        end

                        view
                    else
                        old_method_missing(name, *args, &block)
                    end
                else
                    old_method_missing(name, *args, &block)
                end
            else
                name = name.sub(/^_/, '')

                case name
                when 'on'
                    if block_given?
                        HTML.element.addEventListener(args[0], &block)
                    else
                        HTML.element.addEventListener(args[0], args[1])
                    end
                when 'html'
                    HTML.element.innerHTML = args[0]
                when 'style'
                    HTML.element.style
                when 'text'
                    HTML.element.textContent = args[0]
                when 'title'
                    HTML.element.title = args[0]
                when 'value'
                    HTML.element.value = args[0]
                when 'disabled'
                    HTML.element.disabled = true
                when 'required'
                    HTML.element.required = true
                when 'selected'
                    HTML.element.selected = true
                when 'attribute'
                    HTML.element.setAttribute(args[0], args[1])
                when 'placeholder'
                    HTML.element.placeholder = args[0]
                else
                    old_method_missing(name, *args, &block)
                end
            end
        else
            old_method_missing(name, *args, &block)
        end
    end
end