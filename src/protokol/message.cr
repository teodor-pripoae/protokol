module Protokol
  class Message
    # FIELDS = {} of Symbol => Array(Int32)

    macro required(field_name, field_type, field_order, packed = false)
      field({{field_name}}, {{field_type}}, {{field_order}}, :required, {{packed}})

      def {{field_name.id}} : {{ field_type.id }}|Nil
        @{{field_name.id}}
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = value
      end
    end

    macro optional(field_name, field_type, field_order, packed = false)
      field({{field_name}}, {{field_type}}, {{field_order}}, :optional, {{packed}})

      def {{field_name.id}} : {{ field_type.id }}|Nil
        @{{field_name.id}}
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = value
      end

      def {{field_name.id}}=(value : Nil)
        @{{field_name.id}} = nil
      end
    end

    macro repeated(field_name, field_type, field_order, packed = false)
      field({{field_name}}, {{field_type}}, {{field_order}}, :repeated, {{packed}})

      def {{field_name.id}} : Array({{field_type.id}})|Nil
        if @{{field_name.id}} != nil
          @{{field_name.id}}
        else
          [] of {{field_type.id}}
        end
      end

      def {{field_name.id}}=(value : Array({{ field_type.id }}))
        @{{field_name.id}} = value
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id.id}} = [value]
      end

      def {{field_name.id}}=(value : Nil)
        @{{field_name.id.id}} = nil
      end
    end

    macro protokol(&block)
      FIELDS = [] of Int32
      {{ yield }}
    end

    macro field(field_name, field_type, field_order, field_policy, packed=false)
      {% FIELDS << field_order %}

      def encode_{{field_order}}(buf : Protokol::Buffer)
        {% if field_type == :Bytes %}
          v = [self.{{ field_name.id }}]
        {% else %}
          v = self.{{ field_name.id }}
          v = v.is_a?(Array) ? v : [v]
        {% end %}

        values = v.compact

        {% if field_policy == :required %}
          if values.empty?
            raise Protokol::RequiredFieldNotSetError.new("Field {{ field_name.id }} is required and not set")
          end
        {% end %}

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
          if values.size > 0 && values.first.is_a?(Enum)
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

      def decode_{{field_order}}
        puts "decoding {{field_order}} {{field_name}}"
        ""
      end

      def encode(buf = Protokol::Buffer.new)
        {% for field_order in FIELDS.sort %}
          encode_{{field_order}}(buf)
        {% end %}

        buf.to_s
      end

      def self.decode(buffer : String)
        msg = self.new

        {% for field_order in FIELDS.sort %}
          decode_{{field_order}}
        {% end %}

        msg
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
  end
end
