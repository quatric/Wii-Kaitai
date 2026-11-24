meta:
  id: frhd
  title: FRHD frame bounds (frames.bin)
  file-extension: bin
  endian: be
doc: |
  `FRHD` frame bounds (Let's Dance with Mel B, Wii `ui_videos/*/frames.bin`,
  the binary form of `frames.xml`): the rectangle of the visible part of every
  Bink video frame.
seq:
  - id: magic
    contents: FRHD
  - id: len_header
    type: u4
    doc: 0x40.
  - id: one
    type: u4
  - id: total_frames
    type: u4
  - id: frames_per_set
    type: u4
  - id: padding
    size: 0x40 - 0x14
  - id: zero
    type: u8
  - id: maxb
    type: section
  - id: frms
    type: section
types:
  section:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: '`MAXB` (union of the frame rectangles) or `FRMS` (one per frame).'
      - id: len_body
        type: u4
        doc: 0 or 16 (MAXB); 0 or 16 * frames (FRMS).
      - id: rects
        type: rects
        size: len_body
  rects:
    seq:
      - id: items
        type: rect
        repeat: eos
  rect:
    seq:
      - id: x
        type: s4
      - id: y
        type: s4
      - id: w
        type: s4
      - id: h
        type: s4
