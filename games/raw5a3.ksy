meta:
  id: raw5a3
  title: Raw RGB5A3 save banner (.5a3)
  file-extension: 5a3
  endian: be
doc: Exactly 24,576 bytes = 192 x 64 pixels in GX RGB5A3 4x4 tiles, no header (Wii Chess SaveBanner.5a3).
seq:
  - id: tiles
    type: tile
    repeat: expr
    repeat-expr: (192 / 4) * (64 / 4)
types:
  tile:
    seq:
      - id: pixels
        type: u2
        repeat: expr
        repeat-expr: 16
