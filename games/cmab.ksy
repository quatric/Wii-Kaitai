meta:
  id: cmab
  file-extension: cmab
  endian: le
  title: Grezzo 3DS CMAB material/texture archive
doc: |
  A Nintendo 3DS material-animation container used by Grezzo's CTR/CGFX
  toolchain (seen in *Ocarina of Time 3D* and related 3DS titles): the
  file's own header describes CGFX material/animation data by header
  offsets, but the only part reconstructed here is the embedded `txpt`
  texture table that PICA200 textures are read from.

  All numbers are little endian. The header carries two "base" fields
  (`ofs_txpt_base` at 0x14 and a second base added to it at 0x30) whose
  sum is the absolute offset of the `txpt` chunk; textures' own data
  offsets are relative to a further `data_base` field read from the
  header (0x1c). A `txpt` chunk is: magic `txpt`, a u32 texture count,
  then that many fixed 0x18-byte texture-table entries; immediately after
  the entries comes a `strt` chunk (magic + u32 name count) followed by
  a name-offset table (one u32 per name) and then the packed, NUL
  terminated name strings themselves -- a name's absolute start is
  `name_table + 8 + name_count*4 + name_offset[i]`.

  Each texture-table entry gives the compressed/raw payload size, the
  pixel dimensions, a PICA200 texture format code (mapped to an internal
  decoder id for RGBA8/RGB8/RGBA5551/RGB565/RGBA4/LA8/LA4/L8/A8/L4/ETC1/
  ETC1A4), a numeric id, and the payload's offset relative to
  `data_base`. Reconstructed from the reader in `lib-cmab.c`
  (`ScanCMAB`/`GetCMABEntry`); the surrounding CGFX/material/animation
  data that the rest of the header describes is not modeled here.
seq:
  - id: magic
    contents: "cmab"
  - id: header
    type: header_body
    size: 0x34 - 4
types:
  header_body:
    seq:
      - id: unknown_0x04
        size: 0x14 - 4
        doc: Fields not used by the texture-table reader.
      - id: ofs_txpt_base
        type: u4
        doc: First addend of the absolute `txpt` chunk offset (header offset 0x14).
      - id: ofs_name_table
        type: u4
        doc: Absolute offset of the `strt` name-offset table (header offset 0x18).
      - id: data_base
        type: u4
        doc: Base added to each texture entry's data offset (header offset 0x1c).
      - id: unknown_0x20
        size: 0x30 - 0x20
      - id: ofs_txpt_base2
        type: u4
        doc: Second addend of the absolute `txpt` chunk offset (header offset 0x30).
    instances:
      ofs_txpt:
        value: ofs_txpt_base + ofs_txpt_base2
        doc: Absolute offset of the `txpt` chunk, relative to the start of the file.
      txpt:
        io: _root._io
        pos: ofs_txpt
        type: txpt_chunk
      name_table:
        io: _root._io
        pos: ofs_name_table
        type: name_table_chunk
  txpt_chunk:
    seq:
      - id: magic
        contents: "txpt"
      - id: num_textures
        type: u4
      - id: entries
        type: texture_entry
        repeat: expr
        repeat-expr: num_textures
      - id: strt_magic
        contents: "strt"
      - id: num_names
        type: u4
  texture_entry:
    doc: One 0x18-byte embedded PICA texture record.
    seq:
      - id: data_size
        type: u4
        doc: Size in bytes of this texture's payload.
      - id: unknown
        size: 4
        doc: Not read by GetCMABEntry().
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format
        type: u4
        enum: pica_format
        doc: Raw PICA200 texel-format code (see `cmab_pica_format()` in lib-cmab.c).
      - id: ofs_data
        type: u4
        doc: Payload offset, relative to the enclosing header's `data_base`.
      - id: id
        type: u4
        doc: Numeric texture id.
    instances:
      data:
        io: _root._io
        pos: _parent._parent.data_base + ofs_data
        size: data_size
  name_table_chunk:
    seq:
      - id: strt_magic
        contents: "strt"
      - id: num_names
        type: u4
      - id: name_offsets
        type: u4
        repeat: expr
        repeat-expr: num_names
    instances:
      names_base:
        value: _io.pos
  enums:
    pica_format:
      0x14016752: rgba8
      0x14016754: rgb8
      0x80346752: rgba5551
      0x83636754: rgb565
      0x80336752: rgba4
      0x14016758: la8
      0x67606758: la4
      0x14016757: l8
      0x14016756: a8
      0x67616757: l4
      0x0000675a: etc1
      0x0000675b: etc1a4
