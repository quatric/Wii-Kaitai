meta:
  id: stgs
  title: MySims Agents STGS string table
  file-extension: str
  endian: be
doc: |
  "STGS" string table of MySims Agents (`Text/*.str`). A header, `count`
  `{key_hash, offset}` pairs and a pool of NUL-terminated UTF-8 strings whose
  offsets are relative to the pool start. nintoolbox writes `[hash]` blocks.
seq:
  - id: magic
    contents: 'STGS'
  - id: version
    type: u4
    doc: 5.
  - id: count
    type: u4
  - id: unknown
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
  - id: pool
    size-eos: true
types:
  entry:
    seq:
      - id: key_hash
        type: u4
      - id: offset
        type: u4
        doc: Relative to the start of the string pool.
