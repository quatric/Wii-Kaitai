meta:
  id: tgaimg
  title: Truevision TGA image
  file-extension: tga
  endian: le
doc: Recognised by content (e.g. Cocoto Kart Racer .bkg loading screens). The file size must match the header exactly.
seq:
  - id: id_length
    type: u1
  - id: colour_map_type
    type: u1
    doc: 0.
  - id: image_type
    type: u1
    doc: 2, 3, 10 or 11.
  - id: colour_map_spec
    size: 5
  - id: x_origin
    type: u2
  - id: y_origin
    type: u2
  - id: width
    type: u2
  - id: height
    type: u2
  - id: bits_per_pixel
    type: u1
    doc: 8, 24 or 32.
  - id: descriptor
    type: u1
  - id: image_id
    size: id_length
  - id: pixels
    size-eos: true
