module Protokol
  class Buffer
    WIRES = {
      :int32    => 0,
      :uint32   => 0,
      :sint32   => 0,
      :int64    => 0,
      :uint64   => 0,
      :sint64   => 0,
      :bool     => 0,
      :fixed64  => 1,
      :sfixed64 => 1,
      :double   => 1,
      :string   => 2,
      :bytes    => 2,
      :fixed32  => 5,
      :sfixed32 => 5,
      :float    => 5,
    }

    def self.wire_for(ttype)
      wire = WIRES.fetch(ttype, nil)

      if wire
        wire
      elsif Class === ttype && encodable?(ttype)
        2
      # elsif Module === ttype
        # 0
      else
        raise UnknownType.new(ttype)
      end
    end

    def self.encodable?(ttype)
      return false if ! ttype.is_a?(Class)
      # changed becouse crystal does not have this method
      # ttype.public_method_defined?(:encode)
      ttype.responds_to?(:encode)
    end

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
      @buf = String::Builder.new(buf)
    end

    def to_s
      buf.to_s
    end

    def to_str
      buf.to_s
    end

    def buf
      @buf
    end

    def buf=(new_buf)
      @buf = String::Builder.new(new_buf)
      @cursor = 0
    end

    def length
      remain = buf.slice(@cursor..-1)
      remain.bytesize
    end

    def <<(bytes)
      # bytes = bytes.force_encoding("BINARY") if bytes.respond_to? :force_encoding
      @buf.write(bytes)
    end

    def <<(str : String)
      @buf.write(str.bytes)
    end

    def read(n)
      case n
      when Class
        n.decode(read_string)
      when Symbol
        __send__("read_#{n}")
      when Module
        read_uint64
      else
        read_slice = buf.byteslice(@cursor, n)
        @cursor += n
        return read_slice
      end
    end
  end
end

require "./buffer/encode"
require "./buffer/decode"
