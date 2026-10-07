meta:
  id: capcom_mods
  title: Capcom Ghost Trick MODS animation stream (.mods)
  file-extension: mods
  endian: le
doc: |
  `MODSN3` cutscene animation stream of Ghost Trick: Phantom Detective (17
  retail files, all identified). Detection requires the 8-byte magic,
  `block_stride == 256`, `header_size == 192`, a non-zero frame count, and
  `trailer_offset + 8 * trailer_count == file size` with the trailer count
  between 1 and 10000. The per-frame block contents are not documented.
seq:
  - id: magic
    contents: ['MODSN3', 0x0a, 0]
    doc: '`MODS` + `N3\n\0`.'
  - id: frame_count
    type: u4
  - id: block_stride
    type: u4
    valid: 256
  - id: header_size
    type: u4
    valid: 192
  - id: animation_id
    type: u4
    doc: Animation identifier / CRC (`0x0EFC2ED9` seen).
  - id: header_00_18
    size: 0x28 - 0x18
  - id: trailer_offset
    type: u4
    doc: Offset of the keyframe table.
  - id: trailer_count
    type: u4
  - id: header_rest
    size: header_size - 0x30
instances:
  keyframes:
    pos: trailer_offset
    type: keyframe
    repeat: expr
    repeat-expr: trailer_count
types:
  keyframe:
    seq:
      - id: frame_index
        type: u4
      - id: keyframe_offset
        type: u4
