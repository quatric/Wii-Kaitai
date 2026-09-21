meta:
  id: avtex
  file-extension: thb
  endian: be
  title: Avalanche Software texture header table (.thb)
doc: |
  The texture-header ("thb") half of an Avalanche Software GameCube/Wii
  texture pair; pixel data itself lives in a separate, matching .tbb
  file and is addressed by (offset, byte count) into that file -- it is
  not parsed here, mirroring how this repo leaves out-of-band payloads
  (e.g. BARS' audio chunks) as raw byte ranges.

  Layout: a u32 record count, then that many 12-byte table entries
  (`rec`: offset of this texture's descriptor further down in the same
  .thb file; `tbb_ofs`/`tbb_bytes`: byte range in the companion .tbb).
  Each descriptor is a 32-byte struct; only width/height/format at
  offsets +12/+14/+16 are used by the decoder, so only those are
  modeled -- the rest is kept as opaque padding.
seq:
  - id: num_textures
    type: u4
  - id: table
    type: table_entry
    repeat: expr
    repeat-expr: num_textures
types:
  table_entry:
    seq:
      - id: ofs_descriptor
        type: u4
        doc: Offset, within this .thb file, of this texture's descriptor.
      - id: ofs_tbb
        type: u4
        doc: Offset of the pixel data within the companion .tbb file.
      - id: len_tbb
        type: u4
        doc: Byte length of the pixel data within the companion .tbb file.
    instances:
      descriptor:
        io: _root._io
        pos: ofs_descriptor
        type: texture_descriptor
        size: 32
  texture_descriptor:
    seq:
      - id: unknown0
        size: 12
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format
        type: u2
        doc: GX texture format id (0-6, or 14); see the shared GX texture decoder.
      - id: unknown1
        size-eos: true
