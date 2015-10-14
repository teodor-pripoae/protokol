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
    required :bytes,  :Bytes,  2
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

    # it "encodes multiple inside one buffer" do
    #   msg = SimpleMessage.new :a => 123, :b => "hi mom!"
    #   str = ""
    #
    #   1000.times do
    #     msg.write_delimited(str)
    #   end
    #
    #   1000.times do
    #     dec = SimpleMessage.read_delimited(str)
    #     assert_equal msg, dec
    #   end
    # end
  end
end
