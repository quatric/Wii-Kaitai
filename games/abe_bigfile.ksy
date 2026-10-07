meta:
  id: abe_bigfile
  title: Ubisoft Magma "ABE" BigFile (Rabbids Go Home .BF)
  file-extension: bf
  endian: le
doc: |
  Ubisoft Magma "ABE" BigFile (`RGH.BF`, `RGH.wii.sns.BF`, `RGH.$hd$.bik.BF`
  of Rabbids Go Home), verified on the three retail files of the USA disc
  (15,598 records). Do not confuse it with the Jade `BIG\0` BigFile
  (`jade_bigfile.ksy`).

  The file table is a chain of chunks starting at `table_offset` (the area
  before it is zero padding): `u4 n_slots`, `u4 prev_or_flag`, `u4
  next_chunk_offset`, then `n_slots` records of 200 bytes. The next chunk is
  valid only when the second word is 0 and the third points inside the file;
  `0xaaaaaaaa` and `-1` end the chain. Empty slots start with a NUL name.

  A record's name is `xxxxxxxx.ext` or the key-named `xxxxxxxx\0ext`.
  At the record's data offset is a 0x20-byte data header: `u4 stored_size`,
  `u4 unpacked_size`, `u4 0`, `u4 type`, then the payload at +0x20. Types:
  2 = stored (sizes equal); 4 = LZO1X blocks (`u4 n_blocks`, `n * u4`
  packed sizes, then the 256 KiB blocks back to back); 3 = a `<$shadow$>`
  reference to a file living in a sibling BF; 0 = other records (skipped).
seq:
  - id: magic
    contents: ['ABE', 0]
  - id: version
    type: u4
    doc: Always 4.
  - id: total_files
    type: u4
  - id: unknown_0c
    size: 12
  - id: table_offset
    type: u4
    doc: Offset 0x18; the first table chunk (0x14d8 in the retail files).
  - id: unknown_1c
    size: 20
instances:
  first_chunk:
    pos: table_offset
    type: chunk
types:
  chunk:
    seq:
      - id: n_slots
        type: u4
      - id: prev_or_flag
        type: u4
        doc: 0 when a following chunk is valid.
      - id: next_chunk_offset
        type: u4
      - id: records
        type: record
        repeat: expr
        repeat-expr: n_slots
    instances:
      has_next:
        value: >-
          prev_or_flag == 0 and next_chunk_offset != 0
          and next_chunk_offset != 0xaaaaaaaa and next_chunk_offset != 0xffffffff
      next:
        pos: next_chunk_offset
        type: chunk
        io: _root._io
        if: has_next
  record:
    seq:
      - id: name_field
        size: 0x50
      - id: unknown_50
        size: 8
      - id: size_plus_0x20
        type: u4
        doc: Offset 0x58.
      - id: unknown_5c
        size: 8
      - id: key
        type: u4
        doc: Offset 0x64.
      - id: unknown_68
        size: 4
      - id: data_offset
        type: u4
        doc: Offset 0x6c; absolute.
      - id: unknown_70
        size: 88
    instances:
      is_empty:
        value: name_field[0] == 0
      data_header:
        pos: data_offset
        type: data_header
        io: _root._io
        if: not is_empty
  data_header:
    seq:
      - id: stored_size
        type: u4
      - id: unpacked_size
        type: u4
      - id: zero
        type: u4
      - id: type
        type: u4
        enum: member_type
      - id: reserved
        size: 16
      - id: payload
        size: stored_size
        type:
          switch-on: type
          cases:
            'member_type::lzo_blocks': lzo_blocks
  lzo_blocks:
    seq:
      - id: n_blocks
        type: u4
      - id: packed_sizes
        type: u4
        repeat: expr
        repeat-expr: n_blocks
      - id: blocks_data
        size-eos: true
        doc: LZO1X blocks of 256 KiB unpacked size, back to back.
enums:
  member_type:
    0: other
    2: stored
    3: shadow_reference
    4: lzo_blocks
