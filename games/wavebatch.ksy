meta:
  id: wavebatch
  title: Firebrand Games wave bank (.wavebatch)
  file-extension: wavebatch
  endian: be
doc: |
  "TABW". BOM at +4 (0xFEFF = big endian); this definition assumes BE, little
  endian files need the fields byte-swapped. Subsong headers follow the name
  table and two word tables. DSP streams start with 0x20 coefficients + 0x14
  history per channel plus 0x0c padding.
seq:
  - id: magic
    contents: TABW
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 6 or 7.
  - id: subsong_count
    type: u4
  - id: name_table_size
    type: u4
  - id: unknown_count
    type: u4
  - id: samples_count
    type: u4
  - id: name_table
    size: name_table_size
  - id: unknown_words
    type: u4
    repeat: expr
    repeat-expr: unknown_count
  - id: samples_words
    type: u4
    repeat: expr
    repeat-expr: samples_count
  - id: headers
    type: header
    repeat: expr
    repeat-expr: subsong_count
types:
  header:
    seq:
      - id: name_offset
        type: u4
      - id: codec
        type: u4
        doc: 0 PCM16, 1 PCM8, 2 DSP-ADPCM.
      - id: rate
        type: u4
      - id: channels
        type: u4
      - id: unk10
        size: 8
      - id: stream_offset
        type: u4
      - id: stream_size
        type: u4
      - id: samples_times_channels
        type: u4
