meta:
  id: nclr
  endian: le
  title: Nintendo DS "Nitro" palette (NCLR)
doc: |
  Nintendo DS NCLR ("RLCN") palette container, as read by
  ScanNitroNCLR() in lib-nitro.c. Outer "RLCN" header wraps one
  "TTLP" chunk holding a flat table of BGR555 15-bit colors, later
  expanded to RGBA8 (5 bits per channel scaled to 0..255, alpha
  always opaque).
seq:
  - id: magic
    contents: "RLCN"
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: n_sections
    type: u2
  - id: ttlp
    type: ttlp_chunk
types:
  ttlp_chunk:
    seq:
      - id: magic
        contents: "TTLP"
      - id: chunk_size
        type: u4
      - id: bit_depth
        type: u4
        doc: 3 = 4bpp (16-color banks), 4 = 8bpp (256-color banks).
      - id: padding
        type: u4
      - id: data_size
        type: u4
      - id: data_off
        type: u4
        doc: Relative to this chunk's start (add 0x18 per ScanNitroNCLR).
    instances:
      colors:
        pos: data_off + 0x18
        type: bgr555
        repeat: expr
        repeat-expr: data_size / 2
  bgr555:
    seq:
      - id: raw
        type: u2
    instances:
      r5:
        value: raw & 0x1f
      g5:
        value: (raw >> 5) & 0x1f
      b5:
        value: (raw >> 10) & 0x1f
