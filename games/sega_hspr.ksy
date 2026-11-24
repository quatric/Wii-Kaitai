meta:
  id: sega_hspr
  title: SEGA HSPR sprite sheet (Sakura Wars So Long My Love)
  file-extension: hspr
  endian: le
doc: |
  Container level only. KSPR chunk at 0x10 (payload at 0x20, offsets relative
  to the HSPR chunk): {u32 version 1, 0, N, 0x30}; at 0x30 {sprite count,
  offset of sprite records, count again, offset of a second table (48-byte
  records {0, 0x30, index, sprite record offset})}. Sprite records start 0x10
  after the table offset and are 32 bytes. ".bfX" form with header flag 0x400
  is Melt-compressed first.
seq:
  - id: magic
    contents: HSPR
  - id: size
    type: u4
  - id: header_size
    type: u4
    doc: 0x10.
  - id: flags
    type: u4
    doc: 0 for a plain chunk; bit 0x400 marks the Melt-packed ".bfX" form.
  - id: kspr
    type: kspr
    if: not is_packed
  - id: melt_block
    size: 16
    if: is_packed
    doc: Packed form only (header size 0x10 + this 16-byte block, stream at 0x20).
  - id: melt_stream
    size-eos: true
    if: is_packed
    doc: Melt-compressed data (see sega_melt); decompressing it restores the plain chunk described by `kspr`.
instances:
  is_packed:
    value: (flags & 0x400) != 0
types:
  kspr:
    seq:
      - id: magic
        contents: KSPR
      - id: size
        type: u4
      - id: header_size
        type: u4
      - id: zero
        type: u4
      - id: version
        type: u4
      - id: zero2
        type: u4
      - id: n
        type: u4
      - id: x30
        type: u4
      - id: pad
        size: 0x30 - 0x30
      - id: sprite_count
        type: u4
      - id: sprite_table_offset
        type: u4
      - id: sprite_count2
        type: u4
      - id: second_table_offset
        type: u4
    instances:
      sprites:
        pos: sprite_table_offset + 0x10
        type: sprite
        repeat: expr
        repeat-expr: sprite_count
        io: _root._io
  sprite:
    seq:
      - id: index
        type: u4
      - id: zero0
        type: u4
      - id: kind
        type: u4
        doc: 1..10.
      - id: zero1
        type: u4
      - id: width
        type: f4
      - id: height
        type: f4
      - id: data_offset_a
        type: u4
      - id: track_table_offset_b
        type: u4
