# Render Me Pretty

[![CircleCI](https://circleci.com/gh/tongueroo/render_me_pretty.svg?style=svg)](https://circleci.com/gh/tongueroo/render_me_pretty)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

Let's say you have an error in your ERB template:

```
line 1
<%= sdsd %>
line 3
```

Normally, when render it with ERB you get an error message that looks something like this:

```sh
 NameError:
   undefined local variable or method `sdsd' for #<RenderMePretty::Context:0x00007fcda414d358>
 (erb):2:in `get_binding'
 ./lib/render_me_pretty.rb:71:in `render'
 ./spec/lib/render_me_pretty/erb_spec.rb:41:in `block (3 levels) in <top (required)>'
```

Instead, this library produces an output with an error pointing out the original line in the ERB template like so:

```
NameError evaluating ERB template on line 2 of: spec/fixtures/invalid.erb
1 line 1
2 <%= sdsd %>
3 line 3
```

The output also colorizes the error line in red so it stands out.


## Usage

Here's a simple example:

```ruby
erb = RenderMePretty::Erb.new("/path/to/tempate.erb", a: 3) }
erb.render(a: 4)
```

There's also a convenience class method:

```ruby
RenderMePretty.result("/path/to/tempate.erb", a: 5)
```

### Layout Support

```ruby
RenderMePretty.result("/path/to/tempate.erb", layout: "/path/to/layout.erb")
```

### Custom Context

```ruby
person = Person.new("tung")
erb = RenderMePretty::Erb.new("/path/to/tempate.erb", a: 3, context: person) } # passing context here
erb.render(a: 4)

person = Person.new("tung")
erb = RenderMePretty::Erb.new("/path/to/tempate.erb", a: 3) }
erb.render(person, a: 4) # passing context here
```

The context's methods and instance variables are available in the ERB template. Variables passed at initialization time to `RenderMePretty::Erb.new` or at call time for `render` be set as instance variables to a clone of the original context object.

So in the case above, if there was an `@a` instance variable in the Person object, it will not get respected. Instead the value would be `@a = 4`.

### Context

You can pass in a context object also.  Examples:

A few more examples are in the [erb_spec.rb](spec/lib/render_me_pretty/erb_spec.rb)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'render_me_pretty'
```

And then execute:

    $ bundle

## Contributing

Please fork the project and open a pull request! I'd love your pull requests. Contributions are encouraged and welcomed!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
