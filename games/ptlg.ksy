meta:
  id: ptlg
  title: Next Level Games PTLG texture container
  file-extension:
    - glt
    - rlt
  endian: be
  license: CC0-1.0

doc: |
  Next Level Games GX texture container, magic "PTLG". Used by GameCube
  (.glt, e.g. Super Mario Strikers) and Wii (.rlt, e.g. Mario Strikers
  Charged). The word at 0x08 is zero on GameCube and a hash on Wii; that is
  the discriminator used to tell the two apart. Some builds carry an extra
  padding word before the entry table, detected by peeking the word at
  0x10: if it reads zero, the table starts at 0x20, else at 0x10.

  Reference: nintoolbox project/src/lib-ptlg.c (ExtractPTLGArchive /
  DecodePTLGToPNGDir), cross-checked against KillzXGaming's StrikersRLT.cs
  (Switch-Toolbox).

seq:
  - id: magic
    contents: "PTLG"
  - id: texture_count
    type: u4
  - id: platform_word
    type: u4
    doc: 0 on GameCube; a hash value on Wii.
  - id: padding_0x0c
    type: u4
  - id: word_0x10_peek
    type: u4
  - id: extra_padding
    type: u4
    if: word_0x10_peek == 0

instances:
  is_gamecube:
    value: platform_word == 0
  table_offset:
    value: 'word_0x10_peek == 0 ? 0x20 : 0x10'
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: texture_count
  data_base:
    value: table_offset + texture_count * 16

types:
  entry:
    seq:
      - id: hash
        type: u4
      - id: image_offset
        type: u4
        doc: Relative to data_base (table_offset + texture_count * 16).
      - id: section_size
        type: u4
      - id: unknown
        type: u4
    instances:
      texture:
        pos: _root.data_base + image_offset
        size: section_size
        type: texture

  texture:
    doc: |
      Per-texture header, common prefix, then the raw GX pixel data
      (including the full mip chain). GameCube uses a 16-byte header with
      width/height at 0x0c/0x0e; Wii pads the header out to 32 bytes with
      width/height at 0x0e/0x10.
    seq:
      - id: mip_count
        type: u4
      - id: unknown1
        type: u4
      - id: unknown2
        type: u1
      - id: format
        type: u1
        enum: gx_format
      - id: unknown3
        type: u1
      - id: unknown4
        type: u1
      - id: width_gc
        type: u2
        if: _root.is_gamecube
      - id: height_gc
        type: u2
        if: _root.is_gamecube
      - id: pad_wii
        type: u2
        if: not _root.is_gamecube
      - id: width_wii
        type: u2
        if: not _root.is_gamecube
      - id: height_wii
        type: u2
        if: not _root.is_gamecube
      - id: reserved
        size: 16
        if: not _root.is_gamecube
      - id: pixel_data
        size-eos: true
    enums:
      gx_format:
        2: i4
        3: i8
        4: ia4
        5: rgb5a3
        6: cmpr
        7: rgb565
        8: rgba32
