module Protokol
  class Message
    # FIELDS = {} of Symbol => Array(Int32)

    macro required(field_name, field_type, field_order)
      field({{field_name}}, {{field_type}}, {{field_order}})

      def {{field_name.id}} : {{ field_type.id }}|Nil
        @{{field_name.id}}
      end

      def {{field_name.id}}=(value : {{ field_type.id }})
        @{{field_name.id}} = value
      end
    end

    macro optional(field_name, field_type, field_order)
      field({{field_name}}, {{field_type}}, {{field_order}})

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

    macro repeated(field_name, field_type, field_order)
      field({{field_name}}, {{field_type}}, {{field_order}})

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

    macro field(field_name, field_type, field_order)
      {% if !@type.has_constant?(:fields_ordered) %}
        {% fields_ordered = [field_order] of Int32 %}
      {% end %}
      {% fields_ordered << field_order %}

      def encode_{{field_order}}(buf : Protokol::Buffer)
        v = self.{{ field_name.id }}
        v = v.is_a?(Array) ? v : [v]

        v.compact.each do |val|
          {% if field_type.class_name == "SymbolLiteral" %}
            buf.append_info {{ field_order }}, Protokol::Buffer.wire_for({{ field_type.id.stringify.downcase.id.symbolize }})
            buf.append_{{ field_type.id.stringify.downcase.id }}(val)
          {% else %}
            buf.append_info {{ field_order }}, Protokol::Buffer.wire_for({{ field_type.id }})
            buf.append_string {{ field_type.id }}.encode(val)
          {% end %}
        end
      end

      def decode_{{field_order}}
        puts "decoding {{field_order}} {{field_name}}"
        ""
      end

      def encode
        buf = Protokol::Buffer.new

        puts {{ fields_ordered.sort }}

        {% for field_order in fields_ordered.sort %}
          encode_{{field_order}}(buf)
        {% end %}

        buf.to_s
      end

      def self.decode(buffer : String)
        msg = self.new

        {% for field_order in fields_ordered.sort %}
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
  end
end
