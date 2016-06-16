require "../spec_helper"

class AssignClass1 < Protokol::Message
  protokol do
    required :str_field, :String, 1
    required :int32_field, :Int32, 2
    repeated :int32_arr, :Int32, 4
    optional :f64_field, :Float64, 3
  end
end

class NumericsMessage < Protokol::Message
  protokol do
    required :int32,    :Int32,    1
    required :uint32,   :UInt32,   2
    required :sint32,   :SInt32,   3
    required :fixed32,  :Fixed32,  4
    required :sfixed32, :SFixed32, 5

    required :int64,    :Int64,    6
    required :uint64,   :UInt64,   7
    required :sint64,   :SInt64,   8
    required :fixed64,  :Fixed64,  9
    required :sfixed64, :SFixed64, 10
  end
end

class LendelsMessage < Protokol::Message
  protokol do
    required :string, :String, 1
    required :bytes,  :ByteList,  2
  end
end

class SimpleMessage < Protokol::Message
  protokol do
    optional :a, :Int32,  1
    optional :b, :String, 2
  end
end

class CompositeMessage < Protokol::Message
  protokol do
    required :encodable, "SimpleMessage", 1
  end
end

class EnumsMessage < Protokol::Message
  protokol do
    enum X
      A = 1
    end

    required :a, :X, 1
  end
end

class RepeatedMessage < Protokol::Message
  protokol do
    repeated :a, :Int32, 1
  end
end

class PackedRepeatedMessage < Protokol::Message
  protokol do
    repeated :a, :Int32, 1, packed: true
  end
end

class LargeFieldNumberMessage < Protokol::Message
  protokol do
    required :field_1, :String, 1
    required :field_2, :String, 100
  end
end

class RepeatedNestedMessage < Protokol::Message
  protokol do
    repeated :simple, "SimpleMessage", 1
  end
end

class EnumsDefaultMessage < Protokol::Message
  protokol do
    enum X
      A = 1
      B = 2
    end

    optional :a, :X, 1, default: X::B
  end
end

describe Protokol::Message do
  describe "assign" do
    describe "using builder" do
      it "assigns string" do
        x = AssignClass1.new do |f|
          f.str_field = "myclass"
        end
        x.str_field.should eq("myclass")
      end

      it "assigns int" do
        x = AssignClass1.new do |f|
          f.int32_field = 42
        end
        x.int32_field.class.should eq(Int32)
        x.int32_field.should eq(42)
      end

      it "assigns Float64" do
        x = AssignClass1.new do |f|
          f.f64_field = 3.14
        end
        x.f64_field.class.should eq(Float64)
        x.f64_field.should eq(3.14)
      end

      it "assigns array of int" do
        x = AssignClass1.new do |f|
          f.int32_arr = [2,3,5]
        end
        x.int32_arr.class.should eq(Array(Int32))
        x.int32_arr.should eq([2,3,5])

        x = AssignClass1.new
        x.int32_arr.should eq([] of Int32)
      end

      it "assigns int to array of int" do
        x = AssignClass1.new do |f|
          f.int32_arr = 4
        end
        x.int32_arr.should eq([4])

        x = AssignClass1.new do |f|
          f.int32_arr = 4
          f.int32_arr = 5
        end
        x.int32_arr.should eq([5])
      end
    end

    describe "using field=" do
      it "assigns string" do
        x = AssignClass1.new
        x.str_field = "myothervalue"
        x.str_field.should eq("myothervalue")
      end

      it "assigns int32" do
        x = AssignClass1.new
        x.int32_field = 42
        x.int32_field.should eq(42)
      end

      it "assigns int32 array" do
        x = AssignClass1.new
        x.int32_arr = [4,2]
        x.int32_arr.should eq([4,2])
      end

      it "assigns int32 array as one element" do
        x = AssignClass1.new
        x.int32_arr = 42
        x.int32_arr.should eq([42])
      end
    end
  end

  describe "encode" do
    it "encodes simple AssignClass1 using all attributes" do
      msg = AssignClass1.new do |f|
        f.str_field = "something"
        f.int32_field = 42
        f.f64_field = 3.14
        f.int32_arr = [4,2]
      end

      msg.encode.bytes.should eq([10, 9, 115, 111, 109, 101, 116, 104, 105, 110, 103, 16, 42, 25, 31, 133, 235, 81, 184, 30, 9, 64, 32, 4, 32, 2])
    end

    it "encodes simple AssignClass1 without optional attributes" do
      msg = AssignClass1.new do |f|
        f.str_field = "something"
        f.int32_field = 42
        f.int32_arr = [4,2]
      end

      msg.encode.bytes.should eq([10, 9, 115, 111, 109, 101, 116, 104, 105, 110, 103, 16, 42, 32, 4, 32, 2])
    end

    it "encoded numeric message" do
      msg = NumericsMessage.new do |f|
        f.int32     = Int32::MAX
        f.uint32    = UInt32::MAX
        f.sint32    = Int32::MIN
        f.fixed32   = Int32::MAX.to_u32
        f.sfixed32  = Int32::MIN

        f.int64     = Int64::MAX
        f.uint64    = UInt64::MAX
        f.sint64    = Int64::MIN
        f.fixed64   = Int64::MAX.to_u64
        f.sfixed64  = Int64::MIN
      end
      msg.encode.bytes.should eq([8, 255, 255, 255, 255, 7, 16, 255, 255, 255, 255, 15, 24, 255, 255, 255, 255, 15, 37, 255, 255, 255, 127, 45, 255, 255, 255, 255, 48, 255, 255, 255, 255, 255, 255, 255, 255, 127, 56, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 64, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 73, 255, 255, 255, 255, 255, 255, 255, 127, 81, 255, 255, 255, 255, 255, 255, 255, 255])
    end

    it "encodes strings" do
      msg = LendelsMessage.new do |f|
        f.string = "test\ning"
        f.bytes  = "unixisawesome".bytes
      end

      msg.encode.bytes.should eq([10, 8, 116, 101, 115, 116, 10, 105, 110, 103, 18, 13, 117, 110, 105, 120, 105, 115, 97, 119, 101, 115, 111, 109, 101])
    end

    it "encodes composites messages" do
      msg = CompositeMessage.new do |b|
        b.encodable = SimpleMessage.new do |s|
          s.a = 123
        end
      end

      msg.encode.bytes.should eq([10, 2, 8, 123])
    end

    it "encodes to buffer" do
      msg = SimpleMessage.new do |b|
        b.a = 123
      end

      buf = Protokol::Buffer.new
      msg.encode(buf)
      buf.to_s.should eq("\b{")
    end

    it "encodes enum" do
      msg = EnumsMessage.new do |b|
        b.a = EnumsMessage::X::A
      end

      msg.encode.to_s.should eq("\b\001")
    end

    it "raises if required field is not present" do
      expect_raises Protokol::RequiredFieldNotSetError do
        NumericsMessage.new.encode
      end
    end

    it "encodes repeated field correctly" do
      msg = RepeatedMessage.new do |b|
        b.a = [1, 2, 3, 4, 5]
      end

      msg.encode.bytes.should eq([8, 1, 8, 2, 8, 3, 8, 4, 8, 5])
    end

    it "encodes packed repeated message" do
      msg = PackedRepeatedMessage.new do |b|
        b.a = [1, 2, 3, 4, 5]
      end

      msg.encode.bytes.should eq([8, 5, 1, 2, 3, 4, 5])
    end

    it "encodes large number field" do
      msg = LargeFieldNumberMessage.new
      msg.field_1 = "abc"
      msg.field_2 = "123"

      msg.encode.bytes.should eq([10, 3, 97, 98, 99, 162, 6, 3, 49, 50, 51])
    end

    it "encodes repeated" do
      msg = RepeatedNestedMessage.new do |f|
        f.simple = [SimpleMessage.new do |m|
          m.b = "hello"
        end]
      end

      msg.encode.bytes.should eq([10, 7, 18, 5, 104, 101, 108, 108, 111])
    end
  end

  describe "decode" do
    it "decodes numerics" do
      msg = NumericsMessage.new do |f|
        f.int32     = Int32::MAX
        f.uint32    = UInt32::MAX
        f.sint32    = Int32::MIN
        f.fixed32   = Int32::MAX.to_u32
        f.sfixed32  = Int32::MIN

        f.int64     = Int64::MAX
        f.uint64    = UInt64::MAX
        f.sint64    = Int64::MIN
        f.fixed64   = Int64::MAX.to_u64
        f.sfixed64  = Int64::MIN
      end
      got = NumericsMessage.decode(msg.encode)

      got.int32.should eq(msg.int32)
      got.uint32.should eq(msg.uint32)
      got.sint32.should eq(msg.sint32)
      got.fixed32.should eq(msg.fixed32)
      got.sfixed32.should eq(msg.sfixed32)

      got.int64.should eq(msg.int64)
      got.uint64.should eq(msg.uint64)
      got.sint64.should eq(msg.sint64)
      got.fixed64.should eq(msg.fixed64)
      got.sfixed64.should eq(msg.sfixed64)

      got.should eq(msg)
    end

    it "raises error if type does not match" do
      buf = Protokol::Buffer.new
      buf.append(:string, 1, "testing")

      expect_raises Protokol::WrongTypeError do
        SimpleMessage.decode(buf.to_s)
      end
    end

    it "decodes unknown field" do
      buf = Protokol::Buffer.new
      buf.append(:string, 2, "testing")

      msg = SimpleMessage.decode(buf.to_s)

      msg.a.should eq(nil)
    end

    it "decodes repeated message" do
      msg = RepeatedMessage.new do |m|
        m.a = [1, 2, 3, 4, 5]
      end
      got = RepeatedMessage.decode(msg.encode)

      got.a.should eq(msg.a)
      got.should eq(msg)
    end

    it "decodes packed repeated field" do
      msg = PackedRepeatedMessage.new do |m|
        m.a = [1, 2, 3, 4, 5]
      end
      got = PackedRepeatedMessage.decode(msg.encode)


      got.a.should eq(msg.a)
      got.should eq(msg)
    end

    it "decodes defaults" do
      got = EnumsDefaultMessage.decode("")
      got.a.should eq(EnumsDefaultMessage::X::B)
    end

    it "raises error if required fields are not present" do
      expect_raises Protokol::RequiredFieldNotSetError do
        NumericsMessage.decode("")
      end
    end

    it "decodes enum" do
      msg = EnumsMessage.new do |m|
        m.a = EnumsMessage::X::A
      end
      got = EnumsMessage.decode(msg.encode)
      got.a.should eq(EnumsMessage::X::A)
    end

    it "decodes repeated nested field" do
      simple = [
        SimpleMessage.new{|x| x.a = 1},
        SimpleMessage.new{|x| x.b = "hello"}
      ]

      msg = RepeatedNestedMessage.new{|x| x.simple = simple}.encode
      got = RepeatedNestedMessage.decode(msg)

      got.simple.size.should eq(2)
      got.simple[0].a.should eq(1)
      got.simple[1].b.should eq("hello")
    end

    it "checks equality" do
      a = SimpleMessage.new{|x| x.a = 1}
      b = SimpleMessage.new{|x| x.a = 1}
      a.should eq(b)
      c = SimpleMessage.new{|x| x.a = 2}
      b.should_not eq(c)

      d = EnumsMessage.new{|x| x.a = EnumsMessage::X::A}
      e = EnumsDefaultMessage.new{|x| x.a = EnumsDefaultMessage::X::A}

      d.should_not eq(e)
      e.should_not eq(d)
      d.should_not eq(:sumbol)
      :symbol.should_not eq(d)
    end

    it "checks object_id" do
      inside = [SimpleMessage.new{|x| x.a = 12345}]
      outside = RepeatedNestedMessage.new{|x| x.simple = inside}

      outside.simple.first.object_id.should eq(inside.first.object_id)
    end
  end
end
