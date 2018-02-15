class TestContext
  def initialize(hash={})
    # http://stackoverflow.com/questions/1338960/ruby-templates-how-to-pass-variables-into-inlined-erb
    hash.each do |key, value|
      instance_variable_set('@' + key.to_s, value)
    end
  end

  def my_helper
    "my_helper value"
  end

  def hello(name)
    "hello #{name}"
  end

  def foo_helper
    "foo_helper"
  end
end
