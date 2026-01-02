require 'opal'
require 'native'

module HTTP
    extend self

    def method_missing(name, *args, &block)
        options = {
            body: args[1],
            method: name.upcase
        }

        $$.fetch(args[0], options).then { |response|
            `response.text()`
        }.then { |body|
            block.call(body) if block_given?
        }
    end
end