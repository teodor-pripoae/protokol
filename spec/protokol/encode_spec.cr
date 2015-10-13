require "../spec_helper"

describe Protokol::Buffer do
  it ".append_info" do
    buf = Protokol::Buffer.new
    buf.append_info(1, 0)
    buf.to_s.bytes.should eq([8])

    buf.buf = ""
    buf.append_info(2, 1)
    buf.to_s.bytes.should eq([17])
  end

  it ".append_string" do
    buf = Protokol::Buffer.new
    buf.append_string("testing")
    buf.to_s.bytes.should eq([7, 116, 101, 115, 116, 105, 110, 103])
  end

  it ".append_fixed32" do
    buf = Protokol::Buffer.new
    buf.append_fixed32(1_u32)
    buf.to_s.bytes.should eq([1, 0, 0, 0])

    buf.buf = ""
    buf.append_fixed32(UInt32::MIN)
    buf.to_s.bytes.should eq([0, 0, 0, 0])

    buf.buf = ""
    buf.append_fixed32(UInt32::MAX)
    buf.to_s.bytes.should eq([255, 255, 255, 255])
  end

  it ".append_fixed64" do
    buf = Protokol::Buffer.new
    buf.append_fixed64(1_u64)
    buf.to_s.should eq("\001\0\0\0\0\0\0\0")

    buf.buf = ""
    buf.append_fixed64(UInt64::MIN)
    buf.to_s.should eq("\000\0\0\0\0\0\0\0")

    buf.buf = ""
    buf.append_fixed64(UInt64::MAX)

    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255])#eq("\377\377\377\377\377\377\377\377")
  end

  it ".append_uint32" do
    buf = Protokol::Buffer.new
    buf.append_uint32(1_u32)
    buf.to_s.should eq("\001")

    buf.buf = ""
    buf.append_uint32(UInt32::MIN)
    buf.to_s.should eq("\000")

    buf.buf = ""
    buf.append_uint32(UInt32::MAX)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 15])
  end

  it ".append_int32" do
    buf = Protokol::Buffer.new
    buf.append_int32(1_i32)
    buf.to_s.should eq("\001")

    buf.buf = ""
    buf.append_int32(-1_i32)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255, 255, 1])

    buf.buf = ""
    buf.append_int32(Int32::MIN)
    buf.to_s.bytes.should eq([128, 128, 128, 128, 248, 255, 255, 255, 255, 1])

    buf.buf = ""
    buf.append_int32(Int32::MAX)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 7])
  end

  it ".append_int64" do
    buf = Protokol::Buffer.new
    buf.append_int64(1_i64)
    buf.to_s.should eq("\001")

    buf.buf = ""
    buf.append_int64(-1_i64)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255, 255, 1])

    buf.buf = ""
    buf.append_int64(Int64::MIN)
    buf.to_s.bytes.should eq([128, 128, 128, 128, 128, 128, 128, 128, 128, 1])

    buf.buf = ""
    buf.append_int64(Int64::MAX)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255, 127])
  end

  it ".append_uint64" do
    buf = Protokol::Buffer.new
    buf.append_uint64(1_u64)
    buf.to_s.bytes.should eq([1])

    buf.buf = ""
    buf.append_uint64(UInt64::MIN)
    buf.to_s.bytes.should eq([0])

    buf.buf = ""
    buf.append_uint64(UInt64::MAX)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255, 255, 1])
  end

  it ".append_float" do
    buf = Protokol::Buffer.new
    buf.append_float(3.14_f32)
    buf.to_s.bytes.should eq([195, 245, 72, 64])

    buf.buf = ""
    buf.append_float(0.5_f32)
    buf.to_s.bytes.should eq([0, 0, 0, 63])
  end

  it ".append_double" do
    buf = Protokol::Buffer.new
    buf.append_double(Math::PI)
    buf.to_s.bytes.should eq([24, 45, 68, 84, 251, 33, 9, 64])
  end

  it ".append_bool" do
    buf = Protokol::Buffer.new
    buf.append_bool(true)
    buf.append_bool(false)
    buf.to_s.bytes.should eq([1, 0])
  end

  it ".append_sint32" do
    buf = Protokol::Buffer.new
    buf.append_sint32(-2)
    buf.to_s.bytes.should eq([3])

    buf.buf = ""
    buf.append_sint32(Int32::MAX)
    buf.to_s.bytes.should eq([254, 255, 255, 255, 15])

    buf.buf = ""
    buf.append_sint32(Int32::MIN)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 15])
  end

  it ".append_sfixed32" do
    buf = Protokol::Buffer.new
    buf.append_sfixed32(-2)
    buf.to_s.bytes.should eq([3, 0, 0, 0])

    buf.buf = ""
    buf.append_sfixed32(456)
    buf.to_s.bytes.should eq([144, 3, 0, 0])
  end

  it ".append_sint64" do
    buf = Protokol::Buffer.new
    buf.append_sint64(-2_i64)
    buf.to_s.bytes.should eq([3])

    buf.buf = ""
    buf.append_sint64(Int64::MAX)
    buf.to_s.bytes.should eq([254, 255, 255, 255, 255, 255, 255, 255, 255, 1])

    buf.buf = ""
    buf.append_sint64(Int64::MIN)
    buf.to_s.bytes.should eq([255, 255, 255, 255, 255, 255, 255, 255, 255, 1])

    buf.buf = ""
    buf.append_sfixed64(456_i64)
    buf.to_s.bytes.should eq([144, 3, 0, 0, 0, 0, 0, 0])
  end

  it ".append_sfixed64" do
    buf = Protokol::Buffer.new
    buf.append_sfixed64(Int64::MAX)
    buf.to_s.bytes.should eq([254, 255, 255, 255, 255, 255, 255, 255])
  end

  it ".append_unicode_string" do
    buf = Protokol::Buffer.new
    ingest = "\u{1f63a}" * 5
    ingest.chars.to_a.size.should eq(5)

    expected = ingest.bytes.to_a.size.chr.to_s + ingest
    buf.append_string(ingest)
    actual = buf.to_s
    expected.bytes.to_a.size.should eq(actual.bytes.to_a.size)
    expected.bytes.to_a.should eq(actual.bytes.to_a)
  end

  it ".append_bytes" do
    buf = Protokol::Buffer.new
    buf.append_bytes("testing".bytes)
    buf.to_s.bytes.should eq([7, 116, 101, 115, 116, 105, 110, 103])
  end
end
