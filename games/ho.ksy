meta:
  id: ho
  file-extension: ho
  endian: be
  title: Heavy Iron Studios "Good Engine" .ho package (Wii)
doc: |
  Heavy Iron Studios' Wii asset package (Ratatouille, WALL-E, Up, SpongeBob:
  Truth or Square). Big-endian "HEL\x1a" only -- the little-endian "HEB\x1a"
  PC flavour is not covered. A sector-aligned MAST table locates a single
  SECT table describing every layer; each layer optionally points at a PSL
  asset table (type/offset/size records) and/or a PSLD debug-name table
  (asset id -> name string). Ported from lib-ho.c's `ScanHO`.
seq:
  - id: magic
    contents: [0x48, 0x45, 0x4c, 0x1a]
    doc: |
      "HEL\x1a"; the file's own big-endian "HEB\x1a" variant is not
      supported.
  - id: header_pad
    size: 0x800 - 4
  - id: mast
    type: mast_table
instances:
  sect_pos:
    value: mast.entry.start_sector.as<u4> * 0x800
  sect:
    pos: sect_pos
    type: sect_table
types:
  mast_table:
    seq:
      - id: magic
        contents: "MAST"
      - id: header_pad
        size: 0x20 - 4
      - id: entry
        type: mast_entry
  mast_entry:
    seq:
      - id: unknown
        size: 0x1c
      - id: start_sector
        type: u4
      - id: unknown2
        size: 0x40 - 0x20
  sect_table:
    seq:
      - id: magic
        contents: "SECT"
      - id: unknown_04
        size: 4
      - id: num_layers
        type: u4
      - id: header_pad
        size: 0x20 - 12
      - id: layers
        type: layer
        repeat: expr
        repeat-expr: num_layers
  layer:
    seq:
      - id: lang_word
        type: u4
        doc: Language id is the upper 16 bits of this word.
      - id: unknown_08
        size: 0x1c - 8
      - id: start_sector
        type: u4
      - id: len_body
        type: u4
      - id: unknown_24
        size: 0x38 - 0x24
      - id: ofs_meta
        type: u4
        doc: Offset of this layer's PSL/PSLD meta block, relative to the SECT table.
      - id: unknown_3c
        size: 0x40 - 0x3c
    instances:
      lang_id:
        value: lang_word >> 16
      body:
        io: _root._io
        pos: start_sector.as<u4> * 0x800
        size: len_body
      meta_tag:
        io: _root._io
        pos: _root.sect_pos + ofs_meta
        type: u4
        doc: |
          0x50534c00 ("PSL\x00") or 0x50534c44 ("PSLD"); check this before
          reading `meta_as_psl` / `meta_as_psld`, since only one of the two
          matches at a given offset.
      meta_as_psl:
        io: _root._io
        pos: _root.sect_pos + ofs_meta
        type: psl_meta
        if: meta_tag == 0x50534c00
      meta_as_psld:
        io: _root._io
        pos: _root.sect_pos + ofs_meta
        type: psld_meta
        if: meta_tag == 0x50534c44
  psl_meta:
    doc: |
      Asset table describing one layer: a small header followed by
      `num_slices` slice descriptors. Only slice type 0 (the asset table
      itself, at `layer_start + slice_offset`) is interpreted further;
      other slice types are opaque here.
    seq:
      - id: magic
        contents: [0x50, 0x53, 0x4c, 0x00]
        doc: "PSL\\0"
      - id: len_body
        type: u4
      - id: num_slices
        type: u4
      - id: reserved
        type: u4
      - id: slices
        type: psl_slice
        repeat: expr
        repeat-expr: num_slices
  psl_slice:
    seq:
      - id: type
        type: u4
        doc: 0 = asset table, relative to the owning layer's start.
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
      - id: align
        type: u4
  psl_asset_table:
    seq:
      - id: num_assets
        type: u4
      - id: unknown_04
        type: u4
        doc: Always -1 (0xffffffff) in known samples.
      - id: tag
        size: 24
        doc: 24 bytes of ASCII 't'.
      - id: assets
        type: psl_asset
        repeat: expr
        repeat-expr: num_assets
  psl_asset:
    seq:
      - id: len_padded
        type: u4
      - id: ofs_body
        type: u4
        doc: Offset relative to the owning layer's start.
      - id: len_body
        type: u4
      - id: align
        type: u4
      - id: asset_id
        type: u8
      - id: type_hash
        type: u4
      - id: flags
        type: u4
  psld_meta:
    doc: |
      Debug-name table: a small header, then (in the owning layer's data
      area) `num_names` u32 entry sizes followed by name records starting
      at `ofs_names`, each { u64 asset_id, u32 name_offset, ... } with a
      NUL-terminated name at `name_offset` bytes into the record.
    seq:
      - id: magic
        contents: "PSLD"
      - id: len_body
        type: u4
      - id: num_names
        type: u4
      - id: ofs_names
        type: u4
        doc: Offset of the first name record, relative to the owning layer's start.
