meta:
  id: eqimgset
  title: Mary King's Riding School 2 GUI image set (.imageset.bin)
  endian: be
doc: Raw C-structure dump (uninitialised bytes are 0xcc / 0xcd). File size is exactly 0x148 + 0x48 * count.
seq:
  - id: name
    size: 0x40
    type: strz
    encoding: ASCII
  - id: texture_path
    size: 0x100
    type: strz
    encoding: ASCII
  - id: texture_width
    type: u2
  - id: texture_height
    type: u2
  - id: flag
    type: u1
  - id: pad
    type: u1
  - id: image_count
    type: u2
  - id: images
    type: image
    repeat: expr
    repeat-expr: image_count
types:
  image:
    seq:
      - id: name
        size: 0x40
        type: strz
        encoding: ASCII
      - id: x
        type: u2
      - id: y
        type: u2
      - id: w
        type: u2
      - id: h
        type: u2
