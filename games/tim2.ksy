meta:
  id: tim2
  title: PS2 TIM2 texture (.tm2)
  file-extension: tm2
  endian: le
seq:
  - id: magic
    contents: TIM2
  - id: version
    type: u1
  - id: alignment
    type: u1
  - id: image_count
    type: u2
  - id: pad
    size: 8
  - id: images
    type: image
    repeat: expr
    repeat-expr: image_count
types:
  image:
    seq:
      - id: total_size
        type: u4
      - id: clut_size
        type: u4
      - id: image_size
        type: u4
      - id: header_size
        type: u2
      - id: clut_colours
        type: u2
      - id: format
        type: u1
      - id: mipmaps
        type: u1
      - id: clut_type
        type: u1
      - id: image_type
        type: u1
        doc: 1 ABGR1555, 2 24 bit, 3 32 bit, 4 4 bit, 5 8 bit indexed.
      - id: width
        type: u2
      - id: height
        type: u2
      - id: rest_of_header
        size: header_size - 0x14
      - id: pixels
        size: image_size
      - id: clut
        size: clut_size
