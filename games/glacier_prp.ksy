meta:
  id: glacier_prp
  title: IO Interactive IOPacked property stream (.prp)
  file-extension: prp
  endian: be
doc: |
  "IOPacked v0.1\0", at 0x17 {u32 name count, u32 name table size}, name table
  (NUL-terminated strings) from 0x1f, then 4 bytes and the tag stream. Tags:
  0x01 Array {u32 count} .. 0x7c, 0x02 BeginObject .. 0x7e, 0x03 Reference, 0x04
  Container {u32 count} .. 0x7e, 0x05 Char / 0x06 Bool / 0x07 Int8, 0x08 Int16,
  0x09 Int32, 0x0a Float32, 0x0b Float64, 0x0c String {u32 name index}, 0x0d
  RawData {u32 size, bytes}, 0x0e key {u32 name index}, 0x0f Bitfield {u32 count,
  count x u32 name index}, 0x7d SkipMark, 0x7f end of stream.
seq:
  - id: magic
    contents: ["IOPacked v0.1", 0]
  - id: pad
    size: 0x17 - 14
  - id: name_count
    type: u4
  - id: name_table_size
    type: u4
  - id: names
    size: name_table_size
  - id: unk
    size: 4
  - id: tags
    size-eos: true
