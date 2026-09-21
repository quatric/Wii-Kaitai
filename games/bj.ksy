meta:
  id: bj
  file-extension: tx1
  endian: le
  title: "\"Bj\" engine texture set (Super Karts / Pro Kart, Wii)"
doc: |
  A texture set split across a pair of files: `.tx1` holds a linked list
  of fixed headers, `.tx2` holds the raw paletted pixel data they point
  into. All little-endian on disk (the engine byte-swaps at load time).
  This .ksy covers `.tx1` only; `.tx2` is an opaque pixel blob addressed
  by each record's `tx2_start`/`tx2_length` (2 KiB units).
seq:
  - id: magic
    contents: [0xff, 0x00, 0xcc, 0xfa]
  - id: num_textures
    type: u4
  - id: ofs_first_record
    type: u4
  - id: reserved
    size-eos: true
types:
  record:
    doc: |
      Linked via `ofs_next` (bits 0-23 of the first word; the record
      table itself is walked by following that offset rather than by a
      flat array, hence the lack of a `repeat` here).
      Pixel data for this record lives in the companion .tx2 file, at
      byte offset `tx2_start * 0x800` for `tx2_length * 0x800` bytes.
    seq:
      - id: ofs_next
        type: u4
      - id: ofs_prev
        type: u4
      - id: reserved0
        type: u4
      - id: tx2_start
        type: u2
        doc: Start of this texture's pixel data in the companion .tx2 file, in 2 KiB units.
      - id: tx2_length
        type: u2
        doc: Length of this texture's pixel data, in 2 KiB units.
      - id: format
        type: u1
        doc: 12 = 8-bit paletted.
      - id: num_frames
        type: u1
      - id: reserved1
        type: u2
      - id: flags
        type: u2
        doc: 0x80 = square mip chain stored, 0x1000 = has alpha.
      - id: reserved2
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: num_palette_entries
        type: u4
      - id: palette
        type: u4
        repeat: expr
        repeat-expr: num_palette_entries
        doc: RGBA entries, one per palette slot, each stored as 4 bytes.
