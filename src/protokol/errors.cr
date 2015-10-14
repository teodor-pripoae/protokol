module Protokol
  class InvalidValueError < Exception
    def initialize(name, val)
      super("Invalid Value given for `#{name}`: #{val.inspect}")
    end
  end

  class WrongWireType < Exception
    def initialize(expected, got)
      super("Append called with wrong wire type, expected `#{expected}`, got: #{got}")
    end
  end

  class RequiredFieldNotSetError < Exception
    def initialize(name)
      super("Field #{name} is required but nil")
    end
  end

  class DuplicateFieldNumber < Exception
    def initialize(num, name)
      super("Field number #{num} (#{name}) was already used")
    end
  end
end
