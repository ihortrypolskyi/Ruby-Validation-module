module Validation
  VALIDATION_TYPES = [:presence, :format, :instance_of]

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    @@parameters = {}
    def validate(attr_name, **options)
      @@parameters[attr_name] = options
    end

    def parameters
      @@parameters
    end

    def parameters=(arg)
      @@parameters = arg
    end
  end

  def validate!
    @parameters = self.class.parameters

    @parameters.each do |attr_name, options|
      @attr_name = attr_name
      @options = options

      rescue_exception do
        raise_attribute_error

        options.each do |type, rule|
          @type = type
          @rule = rule

          rescue_exception do
            case type
            when :presence
              validate_presence
            when :format
              validate_format
            when :instance_of
              validate_instance_of
            else
              raise_type_error
            end
          end
        end
      end
    end

    self.class.parameters={}
  end

  def valid?
    validate! && @errors.any? ? false : true
  end

  private

  def raise_attribute_error
    unless @args.include? @attr_name
      raise "Attribute :#{@attr_name} for #{self} does not exist"
    end
  end

  def raise_type_error
    unless VALIDATION_TYPES.include? @type
      raise "'#{@type.capitalize}' is not acceptable validation type. Available types: #{VALIDATION_TYPES}"
    end
  end

  def rescue_exception
    begin
      yield
    rescue RuntimeError => e
      @errors << e.message
    end
  end

  def validate_instance_of
    unless @args[@attr_name].instance_of?(@rule)
      raise "Validation failure: attribute :#{@attr_name} should be an instance of #{@rule}"
    end
  end

  def validate_format
    raise "Validation failure: attribute :#{@attr_name} should match #{@rule}" unless @args[@attr_name] =~ @rule
  end

  def validate_presence
    return unless @rule

    if @args[@attr_name].nil? || @args[@attr_name].empty?
      raise "Validation failure: attribute :#{@attr_name} can't be neither nil nor an empty string"
    end
  end
end
