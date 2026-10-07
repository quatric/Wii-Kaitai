meta:
  id: fuax
  title: Rebel Raiders FUAX string table
  file-extension: bin
  endian: be
doc: |
  "FUAX" string table of Rebel Raiders: Operation Nighthawk
  (`text/<lang>/*.bin`). A header and `count` byte offsets, relative to the
  end of the offset table, to NUL-terminated UTF-16BE strings. nintoolbox
  writes `<name>.txt` as UTF-8 `[index]` blocks.
seq:
  - id: magic
    contents: 'FUAX'
  - id: hash
    type: u4
  - id: lang
    type: str
    size: 4
    encoding: ASCII
    doc: Language tag such as `engl`.
  - id: unknown
    type: u4
  - id: count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Relative to the end of this table.
  - id: pool
    size-eos: true
    doc: UTF-16BE strings, each terminated by a 16-bit NUL.
