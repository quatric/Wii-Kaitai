meta:
  id: bntx
  file-extension: bntx
  endian: le
  title: Nintendo Switch BNTX texture container
doc: |
  The Switch's texture container, standalone or embedded inside BFRES /
  BFFNT / PTCL. Texture pixel data is stored in the Tegra GPU's
  block-linear layout and needs deswizzling to become a normal image;
  this definition only exposes the container structure, not the pixels.

  Layout taken directly from `ScanBNTX()` in lib-bntx.c: a 32-byte binary
  header, then a `platform`-tagged texture-container header ("NX  " on
  real Switch files) holding the texture-info-pointer table, then one
  `BRTI` info block per texture (offsets given by the `TI_*` constants in
  the same file).
seq:
  - id: magic
    contents: "BNTX"
  - id: unknown4
    size: 4
    doc: Second half of the 8-byte magic field; not otherwise interpreted.
  - id: version
    type: u4
  - id: bom
    type: u2
    doc: 0xFEFF; big-endian BNTX files do not occur in practice.
  - id: align_shift
    type: u1
  - id: target_addr_size
    type: u1
  - id: ofs_filename
    type: u4
  - id: flag
    type: u2
  - id: ofs_first_block
    type: u2
  - id: ofs_reloc_table
    type: u4
  - id: len_file
    type: u4
instances:
  container:
    pos: 0x20
    type: texture_container
types:
  texture_container:
    doc: The texture container header, at fixed absolute offset 0x20.
    seq:
      - id: platform
        type: str
        size: 4
        encoding: ASCII
        doc: '`"NX  "` on real Switch files; `"Ounc"`/`"PC  "` also occur.'
      - id: num_textures
        type: u4
      - id: ofs_info_ptrs
        type: u8
        doc: Absolute address of the texture-info pointer array.
    instances:
      info_ptrs:
        pos: ofs_info_ptrs
        type: u8
        repeat: expr
        repeat-expr: num_textures
      textures:
        pos: ofs_info_ptrs
        type: dummy
        repeat: expr
        repeat-expr: 0
    types:
      dummy:
        seq: []
  brti:
    doc: |
      One texture's info block, tagged `BRTI`. Field offsets follow the
      `TI_*` constants in lib-bntx.c, all relative to the start of the
      16-byte-header-skipped info payload (i.e. `BRTI` magic + 16).
    seq:
      - id: magic
        contents: "BRTI"
      - id: header
        size: 12
        doc: '16 bytes total header past `magic`; the remaining 12 are not read by `ScanBNTX()`.'
      - id: flags
        type: u2
      - id: tile_mode
        type: u2
      - id: swizzle
        type: u2
      - id: num_mips
        type: u2
      - id: unknown0e
        size: 2
      - id: format
        type: u4
      - id: unknown14
        size: 8
      - id: width
        type: u4
      - id: height
        type: u4
      - id: depth
        type: u4
      - id: array_count
        type: u4
      - id: layout
        type: u4
        doc: Low 3 bits are `block_height_log2`.
      - id: unknown28
        size: 0x40 - 0x28
      - id: image_size
        type: u4
      - id: alignment
        type: u4
      - id: comp_sel
        type: u4
        doc: Four component selectors, low byte first.
      - id: dim
        type: u1
      - id: unknown4d
        size: 3
      - id: unknown50_pad
        size: 0
    instances:
      block_height_log2:
        value: layout & 7
      name:
        pos: name_addr
        type: pooled_string
        if: name_addr != 0
      name_addr:
        pos: 0x50
        type: u8
      ptrs_addr:
        pos: 0x60
        type: u8
      data_addr:
        pos: ptrs_addr
        type: u8
    doc-ref: 'TI_FLAGS=0x00 TI_TILE_MODE=0x02 TI_SWIZZLE=0x04 TI_NUM_MIPS=0x06 TI_FORMAT=0x0c TI_WIDTH=0x14 TI_HEIGHT=0x18 TI_LAYOUT=0x24 TI_IMAGE_SIZE=0x40 TI_ALIGNMENT=0x44 TI_COMP_SEL=0x48 TI_NAME_ADDR=0x50 TI_PTRS_ADDR=0x60 TI_SIZE=0x90 (all relative to BRTI+16)'
  pooled_string:
    doc: Length-prefixed (u2) UTF-8 string used for BNTX names.
    seq:
      - id: len_name
        type: u2
      - id: name
        type: str
        size: len_name
        encoding: UTF-8
