meta:
  id: nodamemsf
  title: Nodame Cantabile Dream Orchestra score (_msf.bin)
  endian: le
doc: |
  "_MSF", u32 end of payload (= 0x1d + DATA size), 17 more header bytes, "DATA",
  u32 DATA size, then a packed unaligned event stream (padded to 0x4000).
  Records {u32 tag, payload}; total bytes incl. tag: 2 = 14 (note: u16 index,
  u32 tick, u32 value), 0x0a = 13, 0x0b = 11, 0x0c = 11, 0x0f = 12, 0x11 = 13,
  0x12 = 11, 0x13 = 11, 0x16 = 9, 0x17 = 5, 0x18 = 13, 0x2c = 20, 0x2d = 11;
  named tags 8 / 0x15 = {u8 channel, u16 length, NUL-terminated name} + 6 bytes.
seq:
  - id: magic
    contents: _MSF
  - id: end_of_payload
    type: u4
  - id: header_rest
    size: 17
  - id: data_tag
    contents: DATA
  - id: data_size
    type: u4
  - id: events
    size: data_size
