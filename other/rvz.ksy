meta:
  id: rvz
  endian: be
  title: Dolphin WIA/RVZ compressed GameCube/Wii disc image
doc: |
  Dolphin's WIA/RVZ compressed disc image, per lib-rvz.c. Only
  plain GameCube discs are supported by the reference decoder (Wii
  partition hash reconstruction is not implemented), and only
  Zstandard compression. Group/raw-data payload internals (junk-data
  PRNG-packed segments) are not modeled here.
  Spec: https://github.com/dolphin-emu/dolphin/blob/master/docs/WiaAndRvz.md
seq:
  - id: magic
    size: 4
    valid:
      any-of: ['[0x52, 0x56, 0x5a, 0x01]', '[0x57, 0x49, 0x41, 0x01]']
  - id: unknown_04
    size: 0x24 - 4
  - id: iso_file_size
    type: u8
  - id: unknown_2c
    size: 0x48 - 0x2c
  - id: disc
    type: disc_t
types:
  disc_t:
    seq:
      - id: disc_type
        type: u4
        doc: Must be 1 (plain GameCube) -- Wii discs are not supported.
      - id: compression
        type: u4
        doc: Must be 5 (Zstandard) -- other methods are not supported.
      - id: unknown_08
        size: 4
      - id: chunk_size
        type: u4
      - id: disc_head
        size: 0x80
        doc: First 128 bytes of the plain disc image.
      - id: num_partitions
        type: u4
      - id: unknown_94
        size: 0xb4 - 0x94
      - id: num_raw_data
        type: u4
      - id: raw_data_offset
        type: u8
      - id: raw_data_size
        type: u4
      - id: num_groups
        type: u4
      - id: group_offset
        type: u8
      - id: group_size
        type: u4
