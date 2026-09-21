meta:
  id: astc_file
  file-extension: astc
  endian: le
  title: ASTC compressed texture file
doc: |
  The standard on-disk ASTC container: a 16-byte header (magic, block
  footprint, 24-bit little-endian width/height/depth) followed by one
  16-byte compressed block per `block_x`x`block_y` (x`block_z`, unused
  here) tile, row-major, `ceil(width/block_x) * ceil(height/block_y)`
  blocks in total. Each block's own bit-packed ASTC payload is not
  modeled here.
seq:
  - id: magic
    contents: [0x13, 0xab, 0xa1, 0x5c]
  - id: block_x
    type: u1
  - id: block_y
    type: u1
  - id: block_z
    type: u1
  - id: width_raw
    size: 3
    doc: 24-bit little-endian width; see `width`.
  - id: height_raw
    size: 3
    doc: 24-bit little-endian height; see `height`.
  - id: depth_raw
    size: 3
    doc: 24-bit little-endian depth; see `depth`.
  - id: blocks
    size: 16
    repeat: expr
    repeat-expr: num_blocks_x * num_blocks_y
    doc: One 16-byte compressed ASTC block per tile, row-major.
instances:
  width:
    value: width_raw[0].to_i + (width_raw[1].to_i << 8) + (width_raw[2].to_i << 16)
  height:
    value: height_raw[0].to_i + (height_raw[1].to_i << 8) + (height_raw[2].to_i << 16)
  depth:
    value: depth_raw[0].to_i + (depth_raw[1].to_i << 8) + (depth_raw[2].to_i << 16)
  num_blocks_x:
    value: (width + block_x - 1) / block_x
  num_blocks_y:
    value: (height + block_y - 1) / block_y
