module Protokol
  class InvalidValueError < Exception
    def initialize(name, val)
      super("Invalid Value given for `#{name}`: #{val.inspect}")
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
