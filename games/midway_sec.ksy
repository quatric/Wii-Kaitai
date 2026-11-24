meta:
  id: midway_sec
  title: Midway SEC container (.ssf)
  file-extension: ssf
  endian: be
doc: |
  Midway `SEC ` sectioned container (Mortal Kombat: Armageddon, Wii `*.ssf`).
  Entries are 0x800 aligned, ascending, ending inside the file. Payloads are
  nested `SEC ` blocks (models / textures / animations with relocation tables) or
  raw data; the inner layout is not decoded.
seq:
  - id: magic
    contents: 'SEC '
  - id: version
    type: u4
    doc: 4.
  - id: zero
    type: u4
  - id: flags
    type: u4
  - id: count
    type: u4
  - id: header_words
    size: 8
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: tag
        type: u4
        doc: 0x7c801a4f in every file.
      - id: kind
        type: u4
