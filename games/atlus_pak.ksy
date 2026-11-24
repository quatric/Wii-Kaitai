meta:
  id: atlus_pak
  title: Atlus .pak (Trauma Center, Trauma Team)
  file-extension: pak
  endian: le
doc: |
  Atlus `.pak` (Trauma Center: Second Opinion / New Blood, Trauma Team; Wii). A
  flat sequence of members, each a 0x100-byte header and the payload padded to
  a 0x40 boundary; the stream ends with a 0x100-byte terminator (empty name).
  Payloads are usually LZ10-packed (`10` + 24-bit size).
seq:
  - id: members
    type: member
    repeat: until
    repeat-until: _.name == '' or _io.eof
types:
  member:
    seq:
      - id: name
        size: 0xfc
        type: strz
        encoding: ASCII
        doc: NUL padded, may contain `/`.
      - id: len_data
        type: u4
      - id: data
        size: len_data
      - id: padding
        size: (0x40 - len_data % 0x40) % 0x40
