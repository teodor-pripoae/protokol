module Protokol
  class Message
    DEFAULT_TYPES = [
      "int32", "uint32", "sint32", "int64", "uint64", "sint64", "bool",
      "fixed64", "sfixed64", "float64", "string", "bytes", "fixed32", "sfixed32", "float32"
    ]

    macro required(field_name, field_type, field_order, packed = false)
      @{{field_name.id}} = nil
      def {{field_name.id}} : {{ field_type.id }}|Nil
        @{{field_name.id}}
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = value
      end

      field({{field_name}}, {{field_type}}, {{field_order}}, :required, {{packed}})
    end

    macro optional(field_name, field_type, field_order, packed = false)
      @{{field_name.id}} = nil

      def {{field_name.id}} : {{ field_type.id }}|Nil
        @{{field_name.id}}
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = value
      end

      def {{field_name.id}}=(value : Nil)
        @{{field_name.id}} = nil
      end

      field({{field_name}}, {{field_type}}, {{field_order}}, :optional, {{packed}})
    end

    macro repeated(field_name, field_type, field_order, packed = false)
      @{{field_name.id}} = [] of {{ field_type.id }}

      def {{field_name.id}} : Array({{field_type.id}})#|Nil
        val = @{{field_name.id}}
        if val != nil
          val
        else
          [] of {{field_type.id}}
        end
      end

      def {{field_name.id}}=(value : Array({{ field_type.id }}))
        @{{field_name.id}} = value
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = [value]
      end

      def {{field_name.id}}=(value : Nil)
        @{{field_name.id}} = nil
      end

      field({{field_name}}, {{field_type}}, {{field_order}}, :repeated, {{packed}})
    end

    macro protokol(&block)
      FIELDS = [] of Int32
      FIELD_NAMES = [] of Symbol
      DECODERS = {} of Int32 => Proc((self, Protokol::Buffer, Int32), Nil)
      {{ yield }}

      def self.decode(buffer : String)
        buf = Protokol::Buffer.new(buffer)
        decode(buf)
      end

      def self.decode(buf : Protokol::Buffer)
        msg = self.new

        # TODO: test for incomplete buffer
        while buf.length > 0
          fn, wire = buf.read_info

          if !DECODERS.has_key?(fn)
            # We don't have a field for with index fn.
            # Ignore this data and move on.
            buf.skip(wire)
            next
          end

          decoder = DECODERS[fn]

          decoder.call(msg, buf, wire)
        end

        msg
      end
    end

    macro read_field(field_type)
      {% if field_type.class_name == "SymbolLiteral" %}
        {% if DEFAULT_TYPES.includes?(field_type.id.stringify.downcase) %}
          tmp.read_{{ field_type.id.stringify.downcase.id }}
        {% else %}
          {{field_type.id}}.new(tmp.read_uint64.to_i32)
        {% end %}
      {% else %}
        tmp.read({{ field_type.id }})
      {% end %}
    end

    macro wire_for(field_type)
      {% if field_type.class_name == "SymbolLiteral" %}
        {% if DEFAULT_TYPES.includes?(field_type.id.stringify.downcase) %}
          Protokol::Buffer.wire_for({{ field_type.id.stringify.downcase.id.symbolize }})
        {% else %}
          Protokol::Buffer.wire_for(:enum)
        {% end %}
      {% else %}
        Protokol::Buffer.wire_for(:message)
      {% end %}
    end

    macro field(field_name, field_type, field_order, field_policy, packed=false)
      {% FIELDS << field_order %}
      {% FIELD_NAMES << field_name %}

      def encode_{{field_order}}(buf : Protokol::Buffer)
        {% if field_type == :Bytes %}
          values = [self.{{ field_name.id }}].compact
        {% else %}
          v = self.{{ field_name.id }}
          if v.nil?
            values = [] of {{ field_type.id }}
          elsif v.is_a?(Array)
            values = v.compact
          else
            values = [v].compact
          end
        {% end %}

        if values.empty?
          {% if field_policy == :required %}
            raise Protokol::RequiredFieldNotSetError.new("Field {{ field_name.id }} is required and not set")
          {% else %}
            return
          {% end %}
        end

        # If it is packed, pack to a new buffer and later write buffer to current buffer
        {% if packed == true %}
          new_buf = Protokol::Buffer.new
          field_order = 0
        {% else %}
          new_buf = buf
          field_order = {{ field_order }}
        {% end %}

        # Symbols can be built in types and enums
        {% if field_type.class_name == "SymbolLiteral" %}
          if {{ field_type.id }}.is_enum? #values.size > 0 && values.first.is_a?(Enum)
            wire_type = :enum
          else
            wire_type = {{ field_type.id.stringify.downcase.id.symbolize }}
          end
          encode_builtins(new_buf, field_order, values, wire_type)
        {% else %}
          wire_type = :message
          encode_message(new_buf, field_order, values, wire_type)
        {% end %}

        # Write temp buffer to current_buffer
        {% if packed == true %}
          buf.append_info({{ field_order }}, Protokol::Buffer.wire_for(wire_type))
          buf.append_bytes(new_buf.to_s.bytes)
        {% end %}
      end

      def decode_{{field_order}}(buf : Protokol::Buffer, wire : Int32) : Nil
        exp = wire_for({{ field_type }})

        if wire != exp
          raise Protokol::WrongTypeError.new({{ field_name }}, exp, wire)
        end

        {% if field_policy == :repeated && packed == true %}
          len = buf.read_uint64
          tmp = Protokol::Buffer.new(buf.read(len).to_s)

          if self.{{field_name.id}}.nil?
            self.{{field_name.id}} = [] of {{ field_type.id }}
          end
          while tmp.length > 0
            self.{{field_name.id}} << read_field({{ field_type }})
          end
        {% else %}
          tmp = buf
          {% if field_policy == :repeated %}
            val = read_field({{ field_type }})

            if self.{{field_name.id}}.nil?
              self.{{field_name.id}} = [] of {{ field_type.id }}
            end
            self.{{field_name.id}} << val
          {% else %}
            val = read_field({{ field_type }})
            self.{{field_name.id}} = val
          {% end %}
        {% end %}

        nil
      end

      DECODERS[{{field_order}}] = -> (msg : self, buffer : Protokol::Buffer, wire : Int32) {
        msg.decode_{{field_order}}(buffer, wire)
      }


      def ==(other : {{ @type }})
        {% for field_name in FIELD_NAMES %}
          unless self.{{field_name.id}} == other.{{field_name.id}}
            return false
          end
        {% end %}
        return true
      end

      def encode(buf = Protokol::Buffer.new)
        {% for field_order in FIELDS.sort %}
          encode_{{field_order}}(buf)
        {% end %}

        buf.to_s
      end
    end

    def initialize
      @buf = Protokol::Buffer.new
    end

    def initialize(&block)
      @buf = Protokol::Buffer.new
      yield(self)
    end

    def encode_builtins(buf : Protokol::Buffer, field_order : Int32, values, ttype : Symbol)
      values.each do |value|
        buf.append(ttype, field_order, value)
      end
    end

    # def encode_builtins(buf : Protokol::Buffer, field_order : Int32, values : Array(Enum), ttype : Symbol)
    #   values.each do |value|
    #     buf.append(:enum, field_order, value)
    #   end
    # end

    def encode_message(buf : Protokol::Buffer, field_order : Int32, values : Array(Protokol::Message), ttype : Symbol)
      encode_builtins(buf, field_order, values, :message)
    end

    # Do nothing. Compiler is not smart enough to realize that we are not calling this method when array is empty
    def encode_message(buf : Protokol::Buffer, field_order : Int32, values : Array(NoReturn), ttype : Symbol)
    end
  end
end
