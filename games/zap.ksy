meta:
  id: zap
  title: ZAP archive (Thrillville Off the Rails)
  file-extension: zap
  endian: le
doc: |
  Names ending in "/" open a directory, ".." closes one (size 0). File data
  starts at `alignment`; members follow in entry order, each rounded up to it.
seq:
  - id: magic
    contents: ["ZAP", 0]
  - id: alignment
    type: u4
    doc: 0x8000.
  - id: count
    type: u4
  - id: unk
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: crlf
        contents: [0x0d, 0x0a]
      - id: size
        type: u4
      - id: name_length_plus_1
        type: u2
      - id: name
        type: strz
        encoding: ASCII
