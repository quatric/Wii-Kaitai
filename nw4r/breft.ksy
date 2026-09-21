meta:
  id: breft
  file-extension: breft
  endian: be
  title: NW4R BREFT particle-effect texture archive
doc: |
  The texture-carrying sibling of BREFF: same `REFF`-shaped 16-byte
  header as BRRES/BREFF but with magic `REFT`, holding one or more
  `breft_image_t` records (see `lib-breff.h`). Each image is a plain Wii
  GX texture -- format, dimensions, an optional palette and mipmaps --
  addressed exactly like BREFF's items, through the same item-list
  layout.

  Unlike a BRRES TEX0, a BREFT image packs its own small header
  (`breft_image` below) directly in front of the texel data instead of
  reusing the common 16-byte BRSUB header -- BREFT/BREFF sub-files are
  not BRSUBs at all, they only share the outer `REFF`/`REFT` container
  shape with `bres`. Particle-effect textures referenced from a BREFF's
  effect definitions are looked up here by the same name each item
  carries in the item list, mirroring how a BRRES TEX0/PLT0 pair is
  matched by name rather than by pointer.
seq:
  - id: magic
    contents: "REFT"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 9 on Mario Kart Wii, 11 on New Super Mario Bros. Wii.
  - id: len_file
    type: u4
  - id: root_off
    type: u2
    doc: Always 0x10 in practice (immediately after this header).
  - id: num_sections
    type: u2
instances:
  root_header:
    pos: root_off
    type: root_header
types:
  root_header:
    seq:
      - id: magic
        contents: "REFT"
      - id: len_data
        type: u4
      - id: root
        type: root
        size: len_data

  root:
    seq:
      - id: first_item_off
        type: u4
        doc: Offset of the `item_list`, relative to the start of this `root`.
      - id: unknown1
        type: u4
      - id: unknown2
        type: u4
      - id: len_name0
        type: u2
        doc: Name length including the terminating NUL.
      - id: unknown3
        type: u2
      - id: name
        type: strz
        encoding: ASCII
    instances:
      item_list:
        pos: first_item_off
        type: item_list
        io: _io

  item_list:
    seq:
      - id: len_items
        type: u4
      - id: num_items
        type: u2
      - id: unknown1
        type: u2
      - id: items
        type: item_name
        repeat: expr
        repeat-expr: num_items

  item_name:
    seq:
      - id: len_name0
        type: u2
      - id: name
        type: str
        size: len_name0 - 1
        encoding: ASCII
      - id: name_terminator
        size: 1
      - id: data
        type: item_data

  item_data:
    doc: |
      Offset (relative to the start of the item list, i.e.
      `root_header.root.item_list`) and size of one `breft_image_t`; see
      `breft_image` below for its layout.
    seq:
      - id: ofs_data
        type: u4
      - id: len_data
        type: u4

  breft_image:
    doc: |
      `breft_image_t`: a 0x20-byte header (BrawlCrate's `REFTImageHeader`)
      followed by the image data and, if `num_palette_entries` is
      nonzero, palette data right after it.
    seq:
      - id: unknown1
        type: u4
        doc: Always 0.
      - id: width
        type: u2
      - id: height
        type: u2
      - id: len_image
        type: u4
        doc: Total bytes of the base image plus mipmaps.
      - id: image_format
        type: u1
        enum: gx_texture_format
      - id: palette_format
        type: u1
        doc: Wii palette format when indexed; IA8=0, RGB565=1, RGB5A3=2.
      - id: num_palette_entries
        type: u2
        doc: 0 for direct-color formats.
      - id: len_palette
        type: u4
      - id: num_mipmaps
        type: u1
      - id: min_filter
        type: u1
      - id: mag_filter
        type: u1
      - id: reserved
        type: u1
      - id: lod_bias
        type: u4
        doc: Big-endian float bits.
      - id: reserved2
        type: u4
    instances:
      image_data:
        pos: _io.pos
        size: len_image
        io: _io
      palette_data:
        pos: _io.pos + len_image
        size: len_palette
        io: _io
        if: num_palette_entries > 0
enums:
  gx_texture_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: rgba8
    8: ci4
    9: ci8
    10: ci14x2
    14: cmpr
