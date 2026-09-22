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

  There is no magic in .thb. nintoolbox recognizes it structurally:
  1..256 records, a complete 12-byte-per-record table, and every
  descriptor beginning after that table with all 32 bytes inside the
  .thb. Width and height must each be 1..4096; format must be one of
  0..6 or 14. Other descriptor words are not interpreted, so their
  meanings should not be inferred from the offsets alone.

  The companion .tbb range must fit before a texture is decoded. The
  decoder passes that range to the common GX texture decoder, which
  handles tile order and pixel format; there is no image compression
  header in this .thb structure. This schema cannot verify the external
  .tbb bounds or decode the pixel data without that sibling file.
seq:
  - id: num_textures
    type: u4
    doc: Number of table records; detector accepts 1 through 256.
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
        doc: Descriptor prefix ignored by nintoolbox's texture decoder.
      - id: width
        type: u2
        doc: Pixel width; detector requires 1 through 4096.
      - id: height
        type: u2
        doc: Pixel height; detector requires 1 through 4096.
      - id: format
        type: u2
        doc: GX texture format id (0-6, or 14); see the shared GX texture decoder.
      - id: unknown1
        size-eos: true
        doc: Remaining 14 descriptor bytes; opaque to nintoolbox.
