meta:
  id: bombshell
  file-extension:
    - xwi
    - xdx9
  endian: be
  title: Smart Bomb Interactive "BombShell" engine data pack
doc: |
  A flat in-memory-image data pack used by Smart Bomb Interactive's engine
  (Bee Movie Game: Wii `.xwi`, PC `.xdx9`; the same family also backs Hot
  Wheels Velocity X, Pac-Man World Rally, Snoopy vs. the Red Baron and
  Bigfoot). Wii files are big-endian with 32-byte alignment; PC files are
  little-endian and unaligned -- this definition covers the (verified) Wii
  layout, per lib-bombshell.h's header comment.

  A directory table of fixed 24-byte records precedes one "datapack" blob
  per directory, each holding its own sound and texture sub-tables.
seq:
  - id: magic1
    contents: [0x02, 0x01, 0x00, 0xa0]
  - id: magic2
    contents: [0x04, 0x01, 0x00, 0xaf]
  - id: version
    type: u4
    doc: '0x138 in the Bee Movie Game Wii disc.'
  - id: num_dirs
    type: u4
  - id: dirs
    type: directory
    repeat: expr
    repeat-expr: num_dirs
types:
  directory:
    seq:
      - id: unknown1
        type: u4
      - id: dir_type
        type: u4
        enum: dir_type
      - id: unknown2
        type: u4
      - id: unknown3
        type: u4
      - id: len_data
        type: u4
      - id: ofs_datapack
        type: u4
        doc: |
          Relative to the end of the directory table
          (`16 + 24 * _root.num_dirs`).
    instances:
      datapack:
        pos: 16 + 24 * _root.num_dirs + ofs_datapack
        size: len_data
        type: datapack
  datapack:
    doc: |
      Header is 192 bytes on Wii (188 on PC). Field offsets per
      lib-bombshell.h: +4 sound bytes, +8 sound table words, +20 texture
      count, +32 sound count, +108 word list length.
    seq:
      - id: unknown0
        type: u4
      - id: len_sound_bytes
        type: u4
      - id: len_sound_table_words
        type: u4
      - id: unknown0c
        size: 20 - 12
      - id: num_textures
        type: u4
      - id: unknown18
        size: 32 - 24
      - id: num_sounds
        type: u4
      - id: unknown24
        size: 108 - 36
      - id: len_word_list
        type: u4
      - id: unknown6c
        size: 192 - 112
    instances:
      sound_table:
        pos: 192
        type: sound_table_entry
        repeat: expr
        repeat-expr: num_sounds
        if: num_sounds > 0
      # E1 = end of sound table, aligned; sound records sit there.
      # E  = E1 + aligned(sound bytes) + aligned(word list * 4); texture
      # offset list sits there. Both are computed relative offsets not
      # directly expressible without the alignment helper, so are left as
      # documentation rather than guessed at here.
  sound_table_entry:
    seq:
      - id: ofs_record
        type: u4
        doc: Relative to the aligned end of this table (`E1`).
      - id: unknown
        type: u4
  sound_record:
    doc: 'At `E1 + ofs_record`.'
    seq:
      - id: ofs_data
        type: u4
        doc: Relative to `E1`.
      - id: len_data
        type: u4
      - id: sample_rate
        type: u4
      - id: flags
        type: u4
  texture_record:
    doc: |
      32 bytes, at `E + offset` (from the texture offset list at `E`).
      Wii formats 0x45/0xc5/0xc6 are CMPR; 0xc5/0xc6 keep the alpha as a
      second CMPR image in its red channel. PC formats are 0x45 DXT1,
      0xca DXT5, 0xa0 BGRA8, 0x18 BGR8. Only the base level is decoded.
    seq:
      - id: unknown0
        size: 4
      - id: format
        type: u1
      - id: num_mips_minus_1
        type: u1
      - id: log2_width
        type: u1
      - id: log2_height
        type: u1
      - id: ofs_pixels
        type: u4
        doc: Relative to `E`.
      - id: ofs_aux
        type: u4
        doc: Relative to `E`.
      - id: ofs_name
        type: u4
        doc: Relative to `E`.
      - id: ofs_alpha_pixels
        type: u4
        doc: Relative to `E`.
enums:
  dir_type:
    1: interface
    3: link
    4: world
