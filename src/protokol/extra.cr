alias SInt32 = Int32
alias SInt64 = Int64
alias SFixed32 = Int32
alias SFixed64 = Int64
alias Fixed32 = UInt32
alias Fixed64 = UInt64
alias ByteList = Array(UInt8)

class Object
  def self.is_enum?
    false
  end
end

struct Enum
  def self.is_enum?
    true
  end
end
