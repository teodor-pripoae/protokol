require "../spec_helper"

describe Protokol::Buffer do
  it ".read_info" do
    buf = Protokol::Buffer.new
    buf.append_info(1, 2)
    buf.read_info.should eq([1, 2])

    buf.append_info(2, 5)
    buf.read_info.should eq([2,5])
  end

  it ".read_string" do
    buf = Protokol::Buffer.new
    buf.append_string("testing")
    decoded = buf.read_string
    decoded.should eq("testing")
    # assert_equal Encoding.find('utf-8'), decoded.encoding
  end

  it ".read_fixed32" do
    buf = Protokol::Buffer.new
    buf.append_fixed32(123_u32)
    buf.read_fixed32.should eq(123_u32)
  end

  it ".read_fixed64" do
    buf = Protokol::Buffer.new
    buf.append_fixed64(456_u64)
    buf.read_fixed64.should eq(456_u64)
  end

  it ".read_uint32" do
    buf = Protokol::Buffer.new
    buf.append_uint32(1_u32)
    buf.read_uint32.should eq(1)
  end

  it ".read_int32" do
    buf = Protokol::Buffer.new
    buf.append_int32(999_i32)
    buf.read_int32.should eq(999_i32)

    buf.buf = ""
    buf.append_int32(-999_i32)
    buf.read_int32.should eq(-999_i32)
  end

  it ".read_int64" do
    buf = Protokol::Buffer.new
    buf.append_int64(999_i64)
    buf.read_int64.should eq(999_i64)

    buf.buf = ""
    buf.append_int64(-999_i64)
    buf.read_int64.should eq(-999_i64)
  end

  it ".read_uint64" do
    buf = Protokol::Buffer.new
    buf.append_uint64(1_u64)
    buf.read_uint64.should eq(1)
  end

  it ".read_float32" do
    buf = Protokol::Buffer.new
    buf.append_float32(0.5_f32)
    buf.read_float32.should eq(0.5)
  end

  it ".read_float64" do
    buf = Protokol::Buffer.new
    buf.append_float64(Math::PI)
    buf.read_float64.should eq(Math::PI)
  end

  it ".read_bool" do
    buf = Protokol::Buffer.new
    buf.append_bool(true)
    buf.read_bool.should eq(true)

    buf.append_bool(false)
    buf.read_bool.should eq(false)
  end

  it ".read_sint32" do
    buf = Protokol::Buffer.new
    buf.append_sint32(Int32::MIN)
    buf.read_sint32.should eq(Int32::MIN)

    buf.buf = ""
    buf.append_sint32(Int32::MAX)
    buf.read_sint32.should eq(Int32::MAX)
  end

  it ".read_sfixed32" do
    buf = Protokol::Buffer.new
    buf.append_sfixed32(Int32::MIN)
    buf.read_sfixed32.should eq(Int32::MIN)

    buf.buf = ""
    buf.append_sfixed32(Int32::MAX)
    buf.read_sfixed32.should eq(Int32::MAX)
  end

  it ".read_sint64" do
    buf = Protokol::Buffer.new
    buf.append_sint64(Int64::MIN)
    buf.read_sint64.should eq(Int64::MIN)

    buf.buf = ""
    buf.append_sint64(Int64::MAX)
    buf.read_sint64.should eq(Int64::MAX)
  end

  it ".read_sfixed64" do
    buf = Protokol::Buffer.new
    buf.append_sfixed64(Int64::MIN)
    buf.read_sfixed64.should eq(Int64::MIN)

    buf.buf = ""
    buf.append_sfixed64(Int64::MAX)
    buf.read_sfixed64.should eq(Int64::MAX)
  end
end
