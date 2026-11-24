meta:
  id: uber
  title: Rampage Total Destruction .uber sound bank
  file-extension: uber
  endian: be
doc: Sample data is raw DSP-ADPCM in the sibling .samp file.
seq:
  - id: magic
    contents: REBU
  - id: version
    type: u4
    doc: 0x00010001.
  - id: section_offsets
    type: u4
    repeat: expr
    repeat-expr: 6
types:
  rids:
    seq:
      - id: magic
        contents: RIDS
      - id: version
        type: u4
      - id: samp_size
        type: u4
      - id: count
        type: u4
      - id: pad
        size: 16
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: count
        doc: Entry 0 is all 0xff.
  entry:
    seq:
      - id: start_plus_2
        type: u4
      - id: length
        type: u4
      - id: zero
        type: u4
      - id: rate
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: flags
        type: u4
      - id: pad
        size: 0x40 - 16 - 32 - 4
