meta:
  id: nftr
  title: Nintendo DS-style bitmap font (NFTR / RTFN)
  file-extension: nftr
  endian: le
doc: |
  Hannah Montana The Movie (Wii). CGLP (stored "PLGC") holds glyph tiles; CMAP
  (character map) and CWDH (widths) blocks follow. Standard Nitro layout.
seq:
  - id: magic
    contents: RTFN
  - id: bom
    type: u2
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: block_count
    type: u2
  - id: finf
    type: finf
  - id: blocks
    type: block
    repeat: eos
types:
  finf:
    seq:
      - id: tag
        contents: FNIF
      - id: size
        type: u4
      - id: body
        size: size - 8
  block:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size - 8
        type:
          switch-on: tag
          cases:
            '"PLGC"': cglp
  cglp:
    seq:
      - id: tile_width
        type: u1
      - id: tile_height
        type: u1
      - id: tile_bytes
        type: u2
      - id: underline
        type: s1
      - id: max_width
        type: u1
      - id: bpp
        type: u1
        doc: 1, 2, 4 or 8.
      - id: rotation
        type: u1
      - id: tiles
        size-eos: true
        doc: Bits MSB first, row major, bpp bits per pixel.
