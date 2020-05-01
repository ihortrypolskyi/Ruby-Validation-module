require './validation'

class MainClass
  include Validation
  attr_reader  :args, :errors, :parameters

  def initialize(args = {})
    @args = args
    @errors = []
  end
end

class Foo < MainClass
  validate :name, presence: true, format: /\w+/
  validate :number, format: /A-Z{0,3}/, wrong_type: 'foo'
  validate :wrong_attribute, instance_of: Foo
  validate :owner, instance_of: Class
  validate :owners, instance_of: Class
end

foo = Foo.new(name: '', number: 'AA', owner: 'Foo')
foo.validate!
puts foo.errors
puts foo.valid?
puts '----------------------'

class Bar < MainClass
  validate :name, presence: false
  validate :number, format: /A-Z{0,2}/, presence: true
end

bar = Bar.new(name: nil, number: 'A-', owner: MainClass.new)
bar.validate!
puts bar.errors
puts bar.valid?
