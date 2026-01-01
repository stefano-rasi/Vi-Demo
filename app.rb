require 'json'
require 'base64'

require 'opal'
require 'sinatra'

get '/' do
    slim :app
end

get '/views/*' do
    content_type 'application/javascript'

    path = "views/#{params[:splat][0]}"

    builder = Opal::Builder.new()

    builder.append_paths('.')

    builder.build('lib/view/console')
    builder.build(path)

    "#{builder.to_s}\n//# sourceMappingURL=data:application/json;base64,#{Base64.strict_encode64(JSON.dump(builder.source_map.as_json))}"
end