meta:
  id: nsbanim
  file-extension:
    - nsbca
    - nsbta
    - nsbtp
    - nsbva
    - nsbma
    - nsbck
  endian: le
  title: Nitro NNSG3d NSB* animation container (Nintendo DS)
doc: |
  Container shared by the six NSB* animation files used by NNSG3d on the
  Nintendo DS: NSBCA (BCA0/JNT0, joint SRT), NSBTA (BTA0/SRT0, texture
  SRT), NSBTP (BTP0/PAT0, texture pattern), NSBVA (BVA0/VIS0, visibility),
  NSBMA (BMA0/MAT0, material colour), NSBCK (BCK0/CHR0, character/inverse
  -TRS). Ported from `lib-nsbanim.c`/`.h`.

  All six share one NNSG3dResFileHeader + block-offset-table container;
  this definition models that shared outer framing and the
  NNSG3dResDict block structure. The per-unit animation payloads
  (bit-packed SRT streams, visibility bitfields, keyframe tables, etc.)
  are format-specific and not decoded here, matching lib-nsbanim.c's own
  per-format decode functions rather than a single fixed schema.
seq:
  - id: signature
    size: 4
    doc: '"BCA0"/"BTA0"/"BTP0"/"BVA0"/"BMA0"/"BCK0" depending on sub-format.'
  - id: bom
    contents: [0xff, 0xfe]
    doc: Byte-order-mark, always little-endian (0xFEFF read as u16le).
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: header_size
    type: u2
    doc: Offset of the block-offset table (0x10 on retail files).
  - id: num_blocks
    type: u2
  - id: block_offsets
    type: u4
    repeat: expr
    repeat-expr: num_blocks
instances:
  blocks:
    type: block(_index)
    repeat: expr
    repeat-expr: num_blocks
types:
  block:
    params:
      - id: idx
        type: u4
    instances:
      offset:
        value: _root.block_offsets[idx]
      header:
        pos: offset
        type: block_header
        io: _root._io
  block_header:
    doc: NNSG3dResDataBlockHeader, common prefix of every block.
    seq:
      - id: signature
        size: 4
      - id: block_size
        type: u4
  dict_header:
    doc: |
      NNSG3dResDict, immediately following a block_header for animation
      unit dictionaries: revision byte, num_entries byte, size_block u2,
      num_bit u1, unk u1, ofs_entry u2, then num_entries dict_entry
      records of 8 bytes each (u8 key data + u32 unit offset, per
      NNSG3dResDictEntry).
    seq:
      - id: revision
        type: u1
      - id: num_entries
        type: u1
      - id: size_block
        type: u2
      - id: num_bit
        type: u1
      - id: reserved
        type: u1
      - id: ofs_entry
        type: u2
  dict_entry:
    doc: 8 bytes.
    seq:
      - id: key_data
        type: u4
      - id: unit_offset
        type: u4
