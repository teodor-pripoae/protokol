module Protokol
  class Buffer
    WIRES = {
      :enum     => 0,
      :int32    => 0,
      :uint32   => 0,
      :sint32   => 0,
      :int64    => 0,
      :uint64   => 0,
      :sint64   => 0,
      :bool     => 0,
      :fixed64  => 1,
      :sfixed64 => 1,
      :float64  => 1,
      :string   => 2,
      :bytes    => 2,
      :fixed32  => 5,
      :sfixed32 => 5,
      :float32  => 5,
      :message  => 2
    }

    def self.wire_for(ttype)
      wire = WIRES.fetch(ttype, nil)

      if wire
        wire
      elsif ttype.is_a?(String)
        2
      # elsif Module === ttype
        # 0
      else
        raise UnknownType.new(ttype)
      end
    end

    # def self.encodable?(ttype)
    #   return false if ! ttype.is_a?(Class)
    #   # changed becouse crystal does not have this method
    #   # ttype.public_method_defined?(:encode)
    #   ttype.responds_to?(:encode)
    # end

    class StandardError < Exception
    end

    class OutOfRangeError < StandardError
      def initialize(n)
        super("Value of of range: %d" % [n])
      end
    end

    class BufferOverflowError < StandardError
      def initialize(s)
        super("Too many bytes read for %s" % [s])
      end
    end

    class UnknownType < StandardError
      def initialize(s)
        super("Unknown type '%s'" % [s])
      end
    end

    def initialize(buf="")
      @cursor = 0
      @buf = buf #String::Builder.new(buf)
    end

    def to_s
      buf#.to_s
    end

    def to_str
      buf#.to_s
    end

    def buf
      @buf
    end

    def buf=(new_buf)
      @buf = new_buf #String::Builder.new(new_buf)
      @cursor = 0
    end

    def length
      remain = buf.slice(@cursor..-1)
      remain.bytesize
    end

    def <<(bytes : Array(UInt8))
      # Maybe use StringIO here ?
      @buf += String.new(Slice.new(bytes.buffer, bytes.size))
    end

    def <<(str : String)
      @buf += str
    end

    def <<(bytes : Nil)
    end

    def read(n : Class)
      n.decode(read_string)
    end

    def read(n : Symbol)
      case n
      when :info
        read_info
      when :bytes
        read_bytes
      when :string
        read_string
      when :fixed32
        read_fixed32
      when :fixed64
        read_fixed64
      when :int32
        read_int32
      when :int64
        read_int64
      when :uint32
        read_uint32
      when :uint64
        read_uint64
      when :sint32
        read_sint32
      when :sint64
        read_sint64
      when :sfixed32
        read_sfixed32
      when :sfixed64
        read_sfixed64
      when :float32
        read_float32
      when :float64
        read_float64
      when :bool
        read_bool
      else
        raise "type not found"
      end
    end

    def read(n : Int) : Array(UInt8)
      read_slice = @buf.byte_slice(@cursor, n)
      @cursor += n
      return read_slice.bytes
    end
  end
end

require "./buffer/encode"
require "./buffer/decode"
