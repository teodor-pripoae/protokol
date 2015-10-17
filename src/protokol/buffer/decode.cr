module Protokol
  class Buffer
    def read_info
      n    = read_uint64
      fn   = n >> 3
      wire = n & 0x7

      [fn.to_i32, wire.to_i32]
    end

    def read_bytes : Array(UInt8)
      read(read_uint64)
    end

    def read_string : String
      # read_bytes.to_s
      bytes = read_bytes
      String.new(Slice.new(bytes.buffer, bytes.size))
    end

    def read_fixed32 : UInt32
      bytes = read(4)
      unpack32(bytes)
    end

    def read_fixed64 : UInt64
      bytes = read(8)
      x, y = unpack32(bytes[0..3]).to_u64, unpack32(bytes[4..7]).to_u64
      x.to_u64 + (y.to_u64 << 32)
    end

    def read_int32 : Int32
      read_uint32.to_i32
    end

    def read_int64 : Int64
      read_uint64.to_i64
    end

    def read_uint32 : UInt32
      read_uint64.to_u32
    end

    def read_uint64 : UInt64
      n = shift = 0_u64
      while true
        if shift >= 64
          raise Protokol::BufferOverflowError.new("varint")
        end
        b = read(1).first.to_u64

        n |= ((b & 0x7F) << shift)
        shift += 7
        if (b & 0x80) == 0
          return n
        end
      end
    end

    def read_sint32 : Int32
      decode_zigzag(read_uint32)
    end

    def read_sint64 : Int64
      decode_zigzag(read_uint64)
    end

    def read_sfixed32 : Int32
      decode_zigzag(read_fixed32)
    end

    def read_sfixed64 : Int64
      decode_zigzag(read_fixed64)
    end

    def read_float32 : Float32
      bytes = read(4)
      unpack_float32(bytes)
    end

    def read_float64 : Float64
      bytes = read(8)
      unpack_float64(bytes)
    end

    def read_bool
      read_int32 != 0
    end

    def skip(wire)
      case wire
      when 0 then read_uint64
      when 1 then read_fixed64
      when 2 then read_string
      when 5 then read_fixed32
      end
    end

    def unpack32(bytes : Array(UInt8)) : UInt32
      tuple = {bytes[0], bytes[1], bytes[2], bytes[3]}
      (pointerof(tuple) as UInt32*).value
    end

    def unpack_float32(bytes : Array(UInt8)) : Float32
      tuple = {bytes[0], bytes[1], bytes[2], bytes[3]}
      (pointerof(tuple) as Float32*).value
    end

    def unpack_float64(bytes : Array(UInt8)) : Float64
      tuple = {bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7]}
      (pointerof(tuple) as Float64*).value
    end

    private def decode_zigzag(n : UInt32) : Int32
      # (n >> 1) ^ (-(n & 1))

      sign = -(n & 1).to_i32
      (n >> 1).to_i32 ^ sign
    end

    private def decode_zigzag(n : UInt64) : Int64
      sign = -(n & 1).to_i64
      (n >> 1).to_i64 ^ sign
    end
  end
end
