module Protokol
  class Buffer
    BUILTINS = {
      "Int32" => [:int32, :sint32, :sfixed32],
      "UInt32" => [:uint32, :fixed32],
      "Int64" => [:int64, :sint64, :sfixed64],
      "UInt64" => [:uint64, :fixed64],
      "Float32" => [:float32],
      "Float64" => [:float64],
      "String" => [:string],
      "Array(UInt8)" => [:bytes],
      "Bool" => [:bool],
      "Enum" => [:enum],
      "Protokol::Message": [:message]
    }

    macro define_builtins
      {% for klass, types in BUILTINS %}
      def append(ttype : Symbol, field_order : Int32, value : {{ klass.id }})
        if field_order != 0
          append_info(field_order, Protokol::Buffer.wire_for(ttype))
        end

        case ttype
        {% for t in types %}
        when {{ t }}
          append_{{ t.id }}(value)
        {% end %}
        else
          raise WrongWireType.new({{ types }}, ttype)
        end
      end
      {% end %}
    end

    define_builtins

    def append_info(fn : Int32, wire : Int32)
      x = (fn << 3) | wire
      append_uint32(x.to_u32)
    end

    def append_enum(n : Enum)
      append_int32(n.value)
    end

    def append_message(n : Protokol::Message)
      append_string(n.encode)
    end

    def append_fixed32(n : UInt32, tag=false)
      self << pack(n)
    end

    def append_fixed64(n : UInt64)
      self << pack(Int32.new(n & 0xFFFFFFFF))
      self << pack(Int32.new(n >> 32))
    end

    def append_int32(n : Int32)
      append_int64(Int64.new(n))
    end

    def append_uint32(n : UInt32)
      append_uint64(UInt64.new(n))
    end

    def append_int64(n : Int64)
      append_uint64(n.to_u64)
    end

    def append_sint32(n : Int32)
      if n < 0
        append_uint32(((n + 1).abs.to_u32 << 1) + 1)
      else
        append_uint32(n.to_u32 << 1)
      end
    end

    def append_sfixed32(n : Int32)
      if n < 0
        append_fixed32(((n + 1).abs.to_u32 << 1) + 1)
      else
        append_fixed32(n.to_u32 << 1)
      end
    end

    def append_sint64(n : Int64)
      if n < 0
        append_uint64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_uint64(n.to_u64 << 1)
      end
    end

    def append_sfixed64(n : Int64)
      if n < 0
        append_fixed64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_fixed64(n.to_u64 << 1)
      end
    end

    def append_uint64(n : UInt64)
      while true
        bits = UInt8.new(n & 0x7F)
        n >>= 7
        if n == 0
          return self << pack(bits)
        end
        self << pack((bits | 0x80))
      end
    end

    def append_float32(n : Float32)
      self << pack(n)
    end

    def append_float64(n : Float64)
      self << pack(n)
    end

    def append_bool(n : Bool)
      append_int64(n ? 1_i64 : 0_i64)
    end

    def append_string(s : String)
      append_bytes(s.bytes)
    end

    def append_bytes(s : Array(UInt8))
      append_uint64(s.to_a.size.to_u64)
      self << s
    end

    def pack(value : Int8 | UInt8)
      b1 = (pointerof(value) as UInt8*).value
      UInt8[b1]
    end

    def pack(value : Int16 | UInt16)
      b1, b2 = (pointerof(value) as {UInt8, UInt8}*).value
      UInt8[b1, b2]
    end

    def pack(value : Int32 | UInt32 | Float32)
      b1, b2, b3, b4 = (pointerof(value) as {UInt8, UInt8, UInt8, UInt8}*).value
      UInt8[b1, b2, b3, b4]
    end

    def pack(value : Int64 | UInt64 | Float64)
      b1, b2, b3, b4, b5, b6, b7, b8 = (pointerof(value) as {UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8}*).value
      UInt8[b1, b2, b3, b4, b5, b6, b7, b8]
    end
  end
end
