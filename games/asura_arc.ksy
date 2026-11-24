meta:
  id: asura_arc
  title: Rebellion Asura engine "wii" resource archive (.ARC)
  file-extension: arc
  endian: be
doc: |
  Rebellion Asura engine `wii\0` resource archive (PDC World Championship
  Darts, Wii; engine builds on other platforms use other headers). Type 0x15
  members are standard DSP-ADPCM files (header + data), type 0x14 nested U8
  archives.
seq:
  - id: magic
    contents: ['wii', 0]
  - id: len_file
    type: u4
  - id: num_entries
    type: u4
  - id: header_rest
    size: 0xd4
    doc: The archive name three times, 0xBAADF00D padded.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: type
        type: u4
        enum: member_type
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: index
        type: u4
      - id: zero0
        type: u4
      - id: alignment
        type: u4
      - id: zero1
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
enums:
  member_type:
    0x14: u8_archive
    0x15: dsp_adpcm
