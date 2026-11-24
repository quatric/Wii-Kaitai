meta:
  id: swfres
  title: Adobe Flash movie (.swf)
  file-extension: swf
  endian: le
doc: |
  "FWS" plain or "CWS" (zlib after the first 8 bytes). DefineSound 14,
  DefineBitsJPEG 6 (+JPEGTables 8), JPEG2 21, JPEG3 35, Lossless 20 / 36.
seq:
  - id: signature
    size: 3
    doc: FWS or CWS.
  - id: version
    type: u1
  - id: file_length
    type: u4
  - id: plain
    type: movie
    if: signature[0] == 0x46
  - id: compressed
    size-eos: true
    process: zlib
    type: movie
    if: signature[0] == 0x43
types:
  movie:
    seq:
      - id: frame_size
        type: rect
      - id: frame_rate
        type: u2
      - id: frame_count
        type: u2
      - id: tags
        type: tag
        repeat: until
        repeat-until: _.code == 0 or _io.eof
  rect:
    meta:
      bit-endian: be
    seq:
      - id: nbits
        type: b5
      - id: bits
        type: b1
        repeat: expr
        repeat-expr: nbits * 4
      - id: pad
        type: b1
        repeat: expr
        repeat-expr: (8 - ((5 + nbits * 4) % 8)) % 8
  tag:
    seq:
      - id: code_and_length
        type: u2
      - id: long_length
        type: u4
        if: short_length == 0x3f
      - id: body
        size: 'short_length == 0x3f ? long_length : short_length'
    instances:
      code:
        value: code_and_length >> 6
      short_length:
        value: code_and_length & 0x3f
