meta:
  id: hbmmbd
  title: Fishing Master .mbd sound bank
  file-extension: mbd
  endian: le
doc: |
  Streams start at table size + 8 and follow back to back; each is {u32 size -
  4, 16-bit LE interleaved PCM}. Version 1 = "HBMSND" bank (record count at
  0x38), version 3 = categorised bank (NUL-separated category names, count at
  0x4c). Records: {u32 offset, size, 16 (bits), rate, channels, 0, samples,
  extra}. After the records {u32 0, u32 0, u32 count} and entries {u32 length,
  name padded to 4, u32 record index}.
seq:
  - id: table_size
    type: u4
  - id: table_size2
    type: u4
  - id: version
    type: u4
  - id: header
    size: '(version == 1 ? 0x38 : 0x4c) - 12'
  - id: record_count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: record_count
types:
  record:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: bits
        type: u4
      - id: rate
        type: u4
      - id: channels
        type: u4
      - id: zero
        type: u4
      - id: samples
        type: u4
      - id: extra
        type: u4
