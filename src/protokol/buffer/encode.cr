module Protokol
  class Buffer

    def append(ttype, val, fn)
      if fn != 0
        wire = Buffer.wire_for(ttype)
        append_info(fn, wire)
      end

      __send__("append_#{ttype}", val)
    end

    def append_info(fn, wire)
      append_uint32((fn << 3) | wire)
    end

    def append_fixed32(n, tag=false)
      # if n < MinUint32 || n > MaxUint32
        # raise OutOfRangeError.new(n)
      # end

      self << pack(n)
    end

    def append_fixed64(n)
      # if n < MinUint64 || n > UInt64::MAX
        # raise OutOfRangeError.new(n)
      # end

      self << pack(Int32.new(n & 0xFFFFFFFF))
      self << pack(Int32.new(n >> 32))
    end

    def append_int32(n)
      # if n < MinInt32 || n > MaxInt32
        # raise OutOfRangeError.new(n)
      # end

      append_int64(Int64.new(n))
    end

    def append_uint32(n)
      # if n < MinUint32 || n > MaxUint32
        # raise OutOfRangeError.new(n)
      # end

      append_uint64(Int64.new(n))
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

    def append_sint32(n)
      if n < 0
        append_uint32(((n + 1).abs.to_u32 << 1) + 1)
      else
        append_uint32(n.to_u32 << 1)
      end
    end

    def append_sfixed32(n)
      if n < 0
        append_fixed32(((n + 1).abs.to_u32 << 1) + 1)
      else
        append_fixed32(n.to_u32 << 1)
      end
      # append_fixed32((n << 1) ^ (n >> 31))
    end

    def append_sint64(n)
      if n < 0
        append_uint64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_uint64(n.to_u64 << 1)
      end
      # append_uint64((n << 1) ^ (n >> 63))
    end

    def append_sfixed64(n)
      if n < 0
        append_fixed64(((n + 1).abs.to_u64 << 1) + 1)
      else
        append_fixed64(n.to_u64 << 1)
      end
      # append_fixed64((n << 1) ^ (n >> 63))
    end

    def append_uint64(n)
      while true
        bits = UInt8.new(n & 0x7F)
        n >>= 7
        if n == 0
          return self << pack(bits)
        end
        self << pack((bits | 0x80))
      end
    end

    def append_float(n)
      self << pack(n)
    end

    def append_double(n)
      self << pack(n)
    end

    def append_bool(n)
      append_int64(n ? 1_i64 : 0_i64)
    end

    def append_string(s)
      append_uint64(s.bytes.to_a.size)
      self << s.bytes
    end

    def append_bytes(s)
      append_string(s)
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
