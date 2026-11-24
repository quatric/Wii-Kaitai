meta:
  id: txtcdec
  title: 10 Minute Solution / Zhu Zhu Pets compressed text catalog (.txtc)
  file-extension: txtc
  endian: be
doc: |
  Compressed stream: flag-byte LZSS (flags LSB first, 1 = literal, 0 = 2-byte
  match {b0, b1}: position (b0 | b1 << 8) >> 4 & 0xfff, length (b0 & 15) + 3,
  4096-byte ring starting empty at 0). The inflated catalog (types
  `catalog` below) starts "BA DB EE F1".
seq:
  - id: stream
    size-eos: true
types:
  catalog:
    seq:
      - id: magic
        contents: [0xba, 0xdb, 0xee, 0xf1]
      - id: zero
        type: u4
      - id: language_count
        type: u2
      - id: id_count
        type: u2
      - id: key_count
        type: u2
      - id: extra_key_count
        type: u2
      - id: keys
        type: key
        repeat: expr
        repeat-expr: key_count
      - id: languages
        type: language
        repeat: expr
        repeat-expr: language_count
  key:
    seq:
      - id: length
        type: u2
      - id: text
        size: length * 2
        type: str
        encoding: UTF-16BE
  language:
    seq:
      - id: bytes
        type: u4
      - id: strings
        size: bytes
        doc: NUL-separated UTF-16BE strings.
