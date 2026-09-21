meta:
  id: sequence
  endian:
    switch-on: _root.magic
    cases:
      '"CSEQ"': le
      '"SSEQ"': le
      _: be
  title: NintendoWare sequence container (RSEQ/CSEQ/FSEQ/SSEQ)
doc: |
  NintendoWare sound-sequence bytecode container (Wii RSEQ, 3DS
  CSEQ, Wii U/Switch FSEQ, DS SSEQ), per lib-sequence.c. Two shapes
  exist: the legacy Wii RSEQ layout with direct DATA/LABL block
  offsets, and the newer reference-table layout (CSEQ/FSEQ/SSEQ)
  with a block-type table. The bytecode itself (a large opcode set
  documented in lib-sequence.h) is not modeled here.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"RSEQ"', '"CSEQ"', '"FSEQ"', '"SSEQ"']
  - id: bom
    type: u2
    doc: Byte-order mark; only meaningful for FSEQ (0xFEFF = big-endian).
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: body
    type:
      switch-on: magic
      cases:
        '"RSEQ"': rseq_legacy_body
        _: block_table_body
types:
  rseq_legacy_body:
    doc: 'Legacy Wii RSEQ layout (version 0x0100): direct block offsets.'
    seq:
      - id: data_off
        type: u4be
      - id: data_size
        type: u4be
      - id: labl_off
        type: u4be
      - id: labl_size
        type: u4be
  block_table_body:
    doc: |
      Newer layout shared by CSEQ/FSEQ/SSEQ: a reference table of
      {type, offset, size} entries, each type 0x5000 = DATA (code)
      or 0x5001 = LABL (labels).
    seq:
      - id: num_blocks
        type: u2
      - id: unknown_02
        size: 2
      - id: blocks
        type: block_ref
        repeat: expr
        repeat-expr: num_blocks
  block_ref:
    seq:
      - id: block_type
        type: u2
        enum: block_type_t
      - id: unknown_02
        size: 2
      - id: offset
        type: u4
      - id: size
        type: u4
enums:
  block_type_t:
    0x5000: data
    0x5001: labl
