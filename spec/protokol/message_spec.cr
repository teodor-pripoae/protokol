require "../spec_helper"

class AssignClass1 < Protokol::Message
  # FIELDS = [] of Int32
  required :str_field, :String, 1
  required :int32_field, :Int32, 2
  repeated :int32_arr, :Int32, 4
  optional :f64_field, :Float64, 3
end

class NumericsMessage < Protokol::Message
  # FIELDS = [] of Int32
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
      x = AssignClass1.new do |f|
        f.str_field = "something"
        f.int32_field = 42
        f.f64_field = 3.14
        f.int32_arr = [4,2]
      end

      x.encode.bytes.should eq([10, 9, 115, 111, 109, 101, 116, 104, 105, 110, 103, 16, 42, 25, 31, 133, 235, 81, 184, 30, 9, 64, 32, 4, 32, 2])
    end

    it "encodes simple AssignClass1 without optional attributes" do
      x = AssignClass1.new do |f|
        f.str_field = "something"
        f.int32_field = 42
        f.int32_arr = [4,2]
      end

      x.encode.bytes.should eq([10, 9, 115, 111, 109, 101, 116, 104, 105, 110, 103, 16, 42, 32, 4, 32, 2])
    end

    it "encoded numeric message" do
      x = NumericsMessage.new do |f|
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
      x.encode.bytes.should eq([8, 255, 255, 255, 255, 7, 16, 255, 255, 255, 255, 15, 24, 255, 255, 255, 255, 15, 37, 255, 255, 255, 127, 45, 255, 255, 255, 255, 48, 255, 255, 255, 255, 255, 255, 255, 255, 127, 56, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 64, 255, 255, 255, 255, 255, 255, 255, 255, 255, 1, 73, 255, 255, 255, 255, 255, 255, 255, 127, 81, 255, 255, 255, 255, 255, 255, 255, 255])
    end
  end
end
