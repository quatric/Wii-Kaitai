meta:
  id: asobo
  file-extension: drv
  endian: be
  title: Asobo Studio BigFile volume (Wii .DRV)
doc: |
  Asobo Studio's "Internal Cross Technology" BigFile container, as used
  by *Ratatouille* on Wii. Layout after widberg/bff (BigFile v1.06.63);
  the Wii flavour is big-endian. A resource's link header and body are
  opaque blobs here -- their own internal structure is per-class (see
  lib-asobo.c/.h for the handful of decoded classes: Bitmap_Z, Sound_Z,
  Mesh_Z, Material_Z) and a compressed body additionally starts with an
  8-byte little-endian (decompressed size, compressed size) pair
  followed by an LZRS bitstream, neither of which is byte-structured
  enough to model in Kaitai.

  Names throughout are 32-bit hashes (Asobo CRC-32, MSB-first table,
  LSB-first update, lower-cased input), not stored strings.
seq:
  - id: version_string
    type: strz
    encoding: ASCII
    size: 0x100
    doc: 'e.g. "v1.06.63.01 - Asobo Studio - Internal Cross Technology".'
  - id: type
    type: u4
  - id: num_blocks
    type: u4
  - id: buffer_even
    type: u4
  - id: buffer_odd
    type: u4
  - id: len_padded
    type: u4
  - id: version
    type: u4
    repeat: expr
    repeat-expr: 3
  - id: block_headers
    type: block_header
    repeat: expr
    repeat-expr: num_blocks
    doc: Table starting at 0x120; the block data itself starts at the fixed offset 0x800.
types:
  block_header:
    seq:
      - id: num_resources
        type: u4
      - id: len_padded
        type: u4
      - id: len_data
        type: u4
      - id: ofs_working_buffer
        type: u4
      - id: first_name_hash
        type: u4
      - id: checksum
        type: u4
  resource:
    doc: |
      One entry inside a block's resource stream (blocks themselves are
      addressed via `block_headers`, back to back starting at 0x800,
      each padded to its own `len_padded`; this type describes a single
      resource within that stream, which the .ksy does not lay out as
      a repeating array since a block's total byte length -- not its
      resource count alone -- is what bounds it).
    seq:
      - id: len_data
        type: u4
        doc: Size of `link_header` plus the stored (possibly compressed) body.
      - id: len_link_header
        type: u4
      - id: len_decompressed
        type: u4
      - id: len_compressed
        type: u4
        doc: 0 means the body is stored uncompressed.
      - id: class_hash
        type: u4
      - id: name_hash
        type: u4
      - id: link_header
        size: len_link_header
      - id: body
        size: len_data - len_link_header
        doc: |
          Raw when `len_compressed == 0`; otherwise an 8-byte
          little-endian (decompressed size, compressed size) pair
          followed by an LZRS-compressed stream.
