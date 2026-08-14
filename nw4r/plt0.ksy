meta:
  id: plt0
  file-extension: plt0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R PLT0 palette
doc: |
  The colour table for a colour-indexed TEX0. A PLT0 is matched to its
  texture by name, not by pointer: the entry carrying `foo` in
  `Palettes(NW4R)` belongs to the entry carrying `foo` in
  `Textures(NW4R)`.

  Entries are two bytes each in the given `format`, so a whole file is
  `ofs_data + num_entries * 2` bytes -- exactly `len_file` in every sample
  checked, which makes the size field an independent confirmation of
  `num_entries`.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: u4
    doc: Offset from the start of this PLT0 to the colour entries (0x40 observed).
  - id: ofs_name
    type: u4
  - id: format
    type: u4
    enum: gx_palette_format
  - id: num_entries
    type: u2
    doc: |
      Colour count: 16 for a CI4 texture, up to 256 for CI8. The GX
      hardware limit is 16384 (CI14X2).
  - id: reserved
    type: u2
  - id: reserved2
    size: 32
instances:
  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0
  entries:
    pos: ofs_data
    type: u2
    repeat: expr
    repeat-expr: num_entries
    doc: |
      One 16-bit colour per entry, decoded according to `format`. RGB5A3
      is the only one of the three that carries alpha, and it does so by
      stealing a bit: top bit set means opaque RGB555, clear means
      RGBA4443.
types:
  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
enums:
  gx_palette_format:
    0: ia8
    1: rgb565
    2: rgb5a3
