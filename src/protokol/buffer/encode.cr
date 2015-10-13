module Protokol
  class Buffer
    def append_info(fn : Int32, wire : Int32)
      x = (fn << 3) | wire
      append_uint32(x.to_u32)
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
      # if n < MinUint32 || n > MaxUint32
        # raise OutOfRangeError.new(n)
      # end

      append_uint64(UInt64.new(n))
    end

    def append_int64(n : Int64)
      # if n < MinInt64 || n > MaxInt64
        # raise OutOfRangeError.new(n)
      # end

      # if n < 0
        # n = n.to_u64 #UInt64.new(n) | (1_u64 << 63)
        # self << UInt8[128, 128, 128, 128, 128, 128, 128, 128, 128, 1]
        # return
      # end

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
      # append_fixed32((n << 1) ^ (n >> 31))
    end

    def append_sint64(n : Int64)
      if n < 0
        append_uint64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_uint64(n.to_u64 << 1)
      end
      # append_uint64((n << 1) ^ (n >> 63))
    end

    def append_sfixed64(n : Int64)
      if n < 0
        append_fixed64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_fixed64(n.to_u64 << 1)
      end
      # append_fixed64((n << 1) ^ (n >> 63))
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
      # UInt[b2, b1]
    end

    def pack(value : Int32 | UInt32 | Float32)
      b1, b2, b3, b4 = (pointerof(value) as {UInt8, UInt8, UInt8, UInt8}*).value
      UInt8[b1, b2, b3, b4]
      # UInt8[b4, b3, b2, b1]
    end

    def pack(value : Int64 | UInt64 | Float64)
      b1, b2, b3, b4, b5, b6, b7, b8 = (pointerof(value) as {UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8}*).value
      UInt8[b1, b2, b3, b4, b5, b6, b7, b8]
      # UInt8[b8, b7, b6, b5, b4, b3, b2, b1]
    end
  end
end
