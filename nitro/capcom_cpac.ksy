meta:
  id: capcom_cpac
  title: Capcom CPAC multi-section archive (cpac_2d.bin / cpac_3d.bin)
  file-extension: bin
  endian: le
doc: |
  Capcom's DS multi-section archive (Ghost Trick: Phantom Detective, Resident
  Evil: Deadly Silence, Ace Attorney titles). There is no magic; detection is
  structural: `header_length` is a multiple of 8 in `0x20..0x100`, and the
  first section starts with a 24-byte tag header whose `header_size` is 24,
  `version` is 2, `next_chunk_offset` is 24, `key_tag` is `BKEY`/`PKEY` and
  `dat_tag` is `BDAT`/`PDAT`.

  The outer header is an array of `(offset, size)` section descriptors. Entry
  0's offset word is `header_length` itself, which is how the section
  table's length is encoded: there are `header_length / 8` sections.

  A section holds a 32-byte header (the 24-byte tag header plus 8 unused
  bytes) and a table, `table_size` bytes in all counted from the section start;
  member data begins at `section_offset + table_size`.

  * `BKEY`/`BDAT` (models, 2D animation, textures, scripts): 16-byte records,
    each two `(offset, size)` pairs. The high bit of a size marks the member
    as Nintendo LZ11 compressed; offsets and sizes are masked with
    `0x7FFFFFFF`; zero-size halves are skipped.
  * `PKEY`/`PDAT` (palettes): 4-byte descriptors, a `u2` colour-count flag
    (`0x0100` = 256 colours / 512 bytes, otherwise 16 colours / 32 bytes) and
    a `u2` palette bank index; the palette lives at
    `payload_start + bank_index * 32`.
seq:
  - id: sections
    type: section_ref(_index)
    repeat: expr
    repeat-expr: sections_count
instances:
  header_length:
    pos: 0
    type: u4
  sections_count:
    value: header_length / 8
types:
  section_ref:
    params:
      - id: index
        type: s4
    seq:
      - id: offset_word
        type: u4
        doc: For entry 0 this is `header_length`, not a section offset.
      - id: size
        type: u4
    instances:
      offset:
        value: 'index == 0 ? _root.header_length : offset_word'
      body:
        pos: offset
        size: size
        type: section
        io: _root._io
  section:
    seq:
      - id: header_size
        type: u4
        doc: Always 24.
      - id: version
        type: u4
        doc: Always 2.
      - id: key_tag
        type: u4
        enum: key_tag
      - id: next_chunk_offset
        type: u4
        doc: Always 24.
      - id: dat_tag
        type: u4
        enum: dat_tag
      - id: table_size
        type: u4
        doc: Bytes from the section start to the first member payload.
      - id: unknown_18
        size: 8
      - id: table
        type:
          switch-on: key_tag
          cases:
            'key_tag::bkey': block_table(table_size)
            'key_tag::pkey': palette_table(table_size)
    instances:
      payload_start:
        value: table_size
        doc: Payload offset relative to the section start.
  block_table:
    params:
      - id: table_size
        type: u4
    seq:
      - id: records
        type: block_record
        repeat: expr
        repeat-expr: (table_size - 32) / 16
  block_record:
    seq:
      - id: first
        type: member_ref
      - id: second
        type: member_ref
  member_ref:
    seq:
      - id: offset_raw
        type: u4
      - id: size_raw
        type: u4
    instances:
      offset:
        value: offset_raw & 0x7fffffff
        doc: Relative to the section's payload start.
      size:
        value: size_raw & 0x7fffffff
        doc: Stored size; 0 means the slot is unused.
      is_lz11:
        value: (size_raw & 0x80000000) != 0
  palette_table:
    params:
      - id: table_size
        type: u4
    seq:
      - id: descriptors
        type: palette_descriptor
        repeat: expr
        repeat-expr: (table_size - 32) / 4
  palette_descriptor:
    seq:
      - id: color_count_flag
        type: u2
        doc: '`0x0100` = 256 colours (512 bytes), anything else 16 colours (32 bytes).'
      - id: bank_index
        type: u2
        doc: Palette offset is `payload_start + bank_index * 32`.
    instances:
      byte_size:
        value: 'color_count_flag == 0x0100 ? 512 : 32'
enums:
  key_tag:
    0x424b4559: bkey
    0x504b4559: pkey
  dat_tag:
    0x42444154: bdat
    0x50444154: pdat
