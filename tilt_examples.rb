require "tilt/erb"
template = Tilt::ERBTemplate.new("templates/foo.erb")
joe = Person.find("joe")
template.render(joe, x: 35, y: 42)
# If no scope is provided, the template is evaluated within the context of an object created with Object.new.

# A single Template instance's render method may be called multiple times with different scope and locals arguments. Continuing the previous example, we render the same compiled template but this time in jane's scope:

jane = Person.find("jane")
template.render(jane, x: 22, y: nil)
# Blocks can be passed to render for templates that support running arbitrary ruby code (usually with some form of yield). For instance, assuming the following in foo.erb:

# Hey <%= yield %>!
# The block passed to render is called on yield:

template = Tilt::ERBTemplate.new("foo.erb")
template.render { "Joe" }
# => "Hey Joe!"
