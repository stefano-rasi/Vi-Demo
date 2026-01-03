require 'lib/vi/view'

require 'lib/view/window'
require 'lib/view/document'

TEXT = [
    "line 1",
    "line 2",
    "line 3",
    "line 4"
].join("\n")

Window.addEventListener('load') do
    vi = ViView.new(TEXT)

    Document.body.appendChild(vi.element)

    vi.focus()
end