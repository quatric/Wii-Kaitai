meta:
  id: mt_arc
  title: Capcom MT Framework ARC (Wii)
  file-extension: arc
  endian: be
doc: |
  Capcom MT Framework `ARC` archive, big-endian Wii variant (Sengoku Basara 3
  `.arc`). Names are backslash separated with no extension; members are zlib
  streams.
seq:
  - id: magic
    contents: ' CRA'
  - id: version
    type: u2
    doc: 7.
  - id: count
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: type_hash
        type: u4
      - id: len_compressed
        type: u4
      - id: size_shl_3_or_flags
        type: u4
        doc: '`size << 3 | flags`.'
      - id: offset
        type: u4
