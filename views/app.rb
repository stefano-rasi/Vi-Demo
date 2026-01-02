require 'lib/Vi/vi.rb'

require 'lib/View/window'
require 'lib/View/document'

TEXT = [
    "line 1",
    "line 2",
    "line 3",
    "line 4"
].join("\n")

Window.addEventListener('load') do
    vi = Vi.new(TEXT)

    Document.body.appendChild(vi.element)

    vi.focus()
end