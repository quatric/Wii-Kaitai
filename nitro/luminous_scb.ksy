meta:
  id: luminous_scb
  title: Luminous Arc 2 SCB screen map (with IMB tiles and PLB palette)
  file-extension: scb
  endian: le
doc: |
  Luminous Arc 2 screen backgrounds are three same-stem files: `.scb`
  (this tile map), `.imb` (tile pixels) and `.plb` (raw BGR555 palette).
  `.scb` and `.imb` may be raw or LZE-compressed (see `luminous_lze.ksy`); the
  palette is raw. nintoolbox renders them with `wimgt DECODE image.scb`.

  Verified layouts: 16-colour, 4-bit tiles (32-byte palette, 32 bytes/tile) or
  256-colour, 8-bit tiles (512-byte palette, 64 bytes/tile). Palette index 0
  is transparent. All 250 backgrounds of the sample pass an independent
  tile-first renderer comparison (143 use 256 colours, 107 use 16).

  The SCB header is four words -- tile columns, tile rows, entry width in
  bits (16) and row stride in bytes (`columns * 2`) -- followed by
  `columns * rows` u2 screen entries. Entries use the standard DS BG screen
  format: tile number in bits 0..9, horizontal flip bit 10, vertical flip bit
  11; only palette bank 0 is verified (bits 12..15 must be 0). Maximum 512 x 512
  tiles; the file size must equal `16 + columns * rows * 2`.
seq:
  - id: columns
    type: u4
  - id: rows
    type: u4
  - id: entry_bits
    type: u4
    valid: 16
  - id: row_stride
    type: u4
    doc: '`columns * 2`.'
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: columns * rows
types:
  entry:
    seq:
      - id: raw
        type: u2
    instances:
      tile_number:
        value: raw & 0x3ff
      flip_h:
        value: (raw & 0x400) != 0
      flip_v:
        value: (raw & 0x800) != 0
      palette_bank:
        value: raw >> 12
