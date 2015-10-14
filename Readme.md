## Protocol Buffers for Crystal

**This is Alpha version, only encoding works**

Inspired from [beefcake](github.com/protobuf-ruby/beefcake), test cases taken from there.

### Usage

```crystal
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
```

### TODO

- [ ] decoding
- [ ] code generation
- [ ] more test coverage
