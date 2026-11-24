meta:
  id: piz_arc
  title: Family GameShow archive (.piz)
  file-extension: piz
  endian: le
doc: |
  Family GameShow (Wii) `*.piz`. Zero padded to 0x800, then `count` 0x80-byte
  entries. Members are RenderWare `WIIDFF` models, `WIITXD` texture dictionaries,
  `WIIANM` / `WIIUVA` data.
seq:
  - id: magic
    contents: 'PIZ '
  - id: version
    type: u4
    doc: 3.
  - id: count
    type: u4
  - id: filler
    type: u4
    doc: 0xCCCCCCCC.
  - id: padding
    size: 0x800 - 16
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x74
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: hash
        type: u4
