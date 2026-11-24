meta:
  id: mthpstill
  title: Capcom MTHP backgrounds (.mhp, Resident Evil Zero)
  file-extension: mhp
  endian: be
doc: Each frame holds a JPEG whose scan data has no 0x00 stuffing after 0xFF and no EOI (the THP convention).
seq:
  - id: magic
    contents: MTHP
  - id: file_size
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: frame_count
    type: u4
  - id: frames
    type: frame
    repeat: expr
    repeat-expr: frame_count
types:
  frame:
    seq:
      - id: magic
        contents: "THP "
      - id: frame_size
        type: u4
      - id: body
        size: frame_size - 8
