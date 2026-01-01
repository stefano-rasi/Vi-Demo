require 'lib/Vi/vi.rb'

require 'lib/View/window'
require 'lib/View/document'

Window.addEventListener('load') do
    vi = Vi.new("line 1\nline 2\nline 3\nline 4")

    Document.body.appendChild(vi.element)
end