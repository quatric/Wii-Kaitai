meta:
  id: ptex
  title: Virtua Tennis / Sega All-Stars Racing PTEX texture bundle
  file-extension: dat
  endian: be
doc: |
  "PTEX" texture bundle (Virtua Tennis 2009, Sonic & Sega All-Stars Racing,
  `.dat`). Record offsets are relative to 0x10.

  * kind 2 -- CMPR colour plane followed by an I4 alpha plane;
  * kind 0 -- plain CMPR at the padded size `w x h`;
  * kind 3 -- left undecoded by nintoolbox.
seq:
  - id: magic
    contents: 'PTEX'
  - id: file_size
    type: u4
  - id: data_size
    type: u4
    doc: File size minus 0x10.
  - id: marker
    contents: [0x44, 0x33, 0x22, 0x11]
  - id: zero_10
    type: u4
  - id: zero_14
    type: u4
  - id: count
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name_hash
        type: u4
      - id: kind
        type: u4
      - id: used_width
        type: u2
      - id: used_height
        type: u2
      - id: width
        type: u2
        doc: Padded.
      - id: height
        type: u2
        doc: Padded.
      - id: offset
        type: u4
        doc: Relative to 0x10.
      - id: u_scale
        type: f4
      - id: v_scale
        type: f4
      - id: unknown
        type: u4
    instances:
      data:
        pos: 0x10 + offset
        size: "width * height / 2 + (kind == 2 ? width * height / 2 : 0)"
        io: _root._io
        doc: CMPR plane, plus an I4 alpha plane for kind 2.
