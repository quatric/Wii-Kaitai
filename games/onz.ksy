meta:
  id: onz
  title: Sonic Team ONE archive (.one / .onz)
  file-extension: one
  endian: le
doc: |
  Sonic Unleashed (Wii). ".onz" is one Nintendo LZ11 stream containing this
  layout. 8-byte header {"one.", u8 entry count, 3 zero bytes} and 0x40-byte
  records from offset 8; payloads 0x20 aligned.
seq:
  - id: magic
    contents: "one."
  - id: count
    type: u1
  - id: pad
    size: 3
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x38
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
