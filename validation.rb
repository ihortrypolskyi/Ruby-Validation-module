module Validation
  VALIDATION_TYPES = [:presence, :format, :instance_of]

  def self.included(klass)
    klass.extend(ValidationClassMethods)
  end

  module ValidationClassMethods
    @@parameters = {}
    def validate(attr_name, options = {})
      @@parameters[attr_name] = options
    end

    def parameters
      @@parameters
    end

    def parameters=(arg)
      @@parameters=arg
    end
  end

  def validate!
    parameters = self.class.parameters
    puts "PARAMETERS #{parameters}"
    puts "ARGS #{@args}"

    parameters.each do |attr_name, options|
      #rescue_exception { raise_attribute_error(attr_name) }

      options.each do |type, rule|
        rescue_exception do
          case type
          when :presence
            validate_presence(attr_name, rule)
          when :format
           validate_format(attr_name, rule)
          when :instance_of
            validate_instance_of(attr_name, rule)
          else
            raise_type_error(attr_name, type)
          end
        end
      end
    end

    self.class.parameters={}
  end

  def valid?
    validate!
    return false if @errors.any?
    true
  end

  def validate_presence(attr_name, rule)
    return unless rule

    if @args[attr_name].nil? || @args[attr_name].empty?
      raise "Validation failure: attribute :#{attr_name} can't be neither nil nor an empty string"
    end
  end

  def validate_format(attr_name, rule)
    raise "Validation failure: attribute :#{attr_name} should match #{rule}" unless @args[attr_name] =~ rule
  end

  def validate_instance_of(attr_name, rule)
    unless @args[attr_name].instance_of? rule
      raise "Validation failure: attribute :#{attr_name} should be an instance of #{rule}"
    end
  end

  def raise_type_error(attr_name, type)
    unless VALIDATION_TYPES.include? attr_name
      raise "'#{type.capitalize}' is not acceptable validation type. Available types: #{VALIDATION_TYPES}"
    end
  end

  def raise_attribute_error(attr_name)
    unless @args[attr_name]
      raise "Attribute :#{attr_name} for #{self} does not exist"
    end
  end

  def rescue_exception
    begin
      yield
    rescue RuntimeError => e
      @errors << e.message
    end
  end
end
