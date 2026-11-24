meta:
  id: alar2
  title: Ganbarion ALAR archive, big-endian flavour (.aar, Pandora's Tower)
  file-extension: aar
  endian: be
doc: |
  Members are tagged data blocks ("ALIG", "ALOD", "ALMT", "ALMS", ...). Not the
  Jump Ultimate Stars ALAR (see other/alar.ksy).
seq:
  - id: magic
    contents: ALAR
  - id: version
    type: u1
    doc: 2.
  - id: marker
    type: u1
    doc: 0xe1.
  - id: member_count
    type: u2
  - id: pad
    size: 8
  - id: records
    type: record
    repeat: expr
    repeat-expr: member_count
types:
  record:
    seq:
      - id: kind
        type: u1
        doc: "'A'..'D'."
      - id: id
        size: 3
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: flags
        type: u4
        doc: Bit 31 set.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
