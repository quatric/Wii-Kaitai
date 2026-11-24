meta:
  id: wiiidarc
  title: Nippon Ichi WIIIDARC sound archive
  file-extension: dat
  endian: be
doc: |
  Phantom Brave We Meet Again. Members are .wsd waves: u32 0x20, two size
  words, a 0x60-byte DSP header at +0x20, ADPCM data at +0x80.
seq:
  - id: magic
    contents: WIIIDARC
  - id: count
    type: u4
  - id: pad
    size: 0x14
  - id: ids
    type: u2
    repeat: expr
    repeat-expr: count
  - id: align
    size: (-(count * 2)) % 0x20
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: zero
        type: u4
      - id: unk
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
