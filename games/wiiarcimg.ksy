meta:
  id: wiiarcimg
  title: '"wii" resource archive (Ski-Doo Snowmobile Challenge, Mere Mortals engine)'
  file-extension: arc
  endian: be
doc: |
  Variant 1 (sound ARCs) holds DSP-ADPCM images; variant 2 (MUSIC.ARC) has
  absolute offsets and raw s16 mono PCM. Type 2 image resources have a 0x60-byte
  header {BE u16 w, h, padded w, padded h, ... GX format at +0x0c}.
seq:
  - id: magic
    contents: ["wii", 0]
  - id: header_size
    type: u4
  - id: resource_count
    type: u4
  - id: variant
    type: u4
  - id: name_table_offset
    type: u4
  - id: header_size2
    type: u4
  - id: pad
    size: 0xe0 - 0x18
  - id: info
    type: info
  - id: pad2
    size: 0x104 - 0xe0 - 20
  - id: records
    type: record
    repeat: expr
    repeat-expr: resource_count
types:
  info:
    seq:
      - id: two
        type: u4
      - id: header_size
        type: u4
      - id: data_base
        type: u4
      - id: fixup_size
        type: u4
      - id: data_size
        type: u4
  record:
    seq:
      - id: type
        type: u4
      - id: size
        type: u4
      - id: offset
        type: u4
        doc: Into the data area (variant 1) or absolute (variant 2).
      - id: id
        type: u4
      - id: zero0
        type: u4
      - id: align
        type: u4
        doc: 0x20.
      - id: zero1
        size: 8
