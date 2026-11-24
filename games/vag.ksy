meta:
  id: vag
  title: Sony VAGp PS-ADPCM
  file-extension: vag
  endian: be
seq:
  - id: magic
    contents: VAGp
  - id: version
    type: u4
  - id: zero
    type: u4
  - id: data_bytes
    type: u4
  - id: rate
    type: u4
  - id: pad
    size: 12
  - id: name
    size: 16
    type: strz
    encoding: ASCII
  - id: frames
    type: frame
    repeat: eos
types:
  frame:
    seq:
      - id: shift_filter
        type: u1
        doc: shift | filter << 4.
      - id: flags
        type: u1
      - id: nibbles
        size: 14
