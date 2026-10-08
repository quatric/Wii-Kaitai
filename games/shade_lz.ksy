meta:
  id: shade_lz
  title: ShadeLz compression (Inazuma Eleven Strikers)
  endian: le
doc: |
  ShadeLz, the LZ scheme of Shade / Level-5's Inazuma Eleven Strikers. Members
  of `dat.bin` are headerless; elsewhere an optional 12-byte header
  `{FC AA 55 A7, u4 unpacked_size, u4 stored_size}` precedes the token stream.
  Without a header the unpacked size is the sum of all token lengths.

  Tokens (first byte `f`):

  * `f & 0x80` -- copy: `len = ((f >> 5) & 3) + 4`, `dist = ((f & 0x1f) << 8) |
    next byte`, copy `len` bytes from `dist` bytes back; `dist` becomes the
    "previous distance";
  * `(f & 0x60) == 0x60` -- copy `f & 0x1f` bytes from the previous distance;
  * `f & 0x40` (and not the case above) -- run of one byte: `len = (f & 0xf) + 4`,
    or if `f & 0x10`, `len = (((f & 0xf) << 8) | next byte) + 4`; then the byte to
    repeat;
  * otherwise literal: if `f & 0x20`, `len = ((f & 0x1f) << 8) | next byte`, else
    `len = f`; then `len` literal bytes.
seq:
  - id: tokens
    type: token
    repeat: eos
    doc: |
      Token stream. For files that start with the 12-byte `header` below, skip
      it first (parse from offset 12); `dat.bin` members are headerless.
types:
  header:
    seq:
      - id: magic
        contents: [0xfc, 0xaa, 0x55, 0xa7]
      - id: unpacked_size
        type: u4
      - id: stored_size
        type: u4
  token:
    seq:
      - id: f
        type: u1
      - id: copy_dist_low
        type: u1
        if: is_copy
      - id: run_len_ext
        type: u1
        if: is_run and (f & 0x10) != 0
      - id: run_byte
        type: u1
        if: is_run
      - id: literal_len_ext
        type: u1
        if: is_literal and (f & 0x20) != 0
      - id: literal_data
        size: literal_len
        if: is_literal
    instances:
      is_copy:
        value: (f & 0x80) != 0
      is_same_dist_copy:
        value: (f & 0x80) == 0 and (f & 0x60) == 0x60
      is_run:
        value: (f & 0x80) == 0 and (f & 0x60) != 0x60 and (f & 0x40) != 0
      is_literal:
        value: (f & 0xc0) == 0
      literal_len:
        value: '(f & 0x20) != 0 ? (((f & 0x1f) << 8) | literal_len_ext) : f'
        if: is_literal
