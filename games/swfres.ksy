meta:
  id: swfres
  title: Adobe Flash movie (.swf)
  file-extension: swf
  endian: le
doc: |
  "FWS" plain or "CWS" zlib after the first 8 bytes. Tag header is u16
  (type << 6 | length), length 0x3f means a u32 length follows. DefineSound 14,
  DefineBitsJPEG 6 (+JPEGTables 8), JPEG2 21, JPEG3 35, Lossless 20 / 36.
seq:
  - id: signature
    size: 3
    doc: FWS or CWS.
  - id: version
    type: u1
  - id: file_length
    type: u4
  - id: body
    size-eos: true
    doc: For CWS this is a zlib stream; for FWS a RECT, frame rate/count and tags.
types:
  tag:
    seq:
      - id: code_and_length
        type: u2
      - id: long_length
        type: u4
        if: (code_and_length & 0x3f) == 0x3f
    instances:
      code:
        value: code_and_length >> 6
