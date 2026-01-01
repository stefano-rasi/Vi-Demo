require 'opal'
require 'native'

module HTTP
    def HTTP.method_missing(name, *args, &block)
        options = {
            body: args[1],
            method: name.upcase
        }

        $$.fetch(args[0], options).then { |response|
            `response.text()`
        }.then { |body|
            if block_given?
                block.call(body)
            end
        }
    end
end