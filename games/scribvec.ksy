meta:
  id: scribvec
  title: Scribblenauts Unlimited vector mesh
  endian: le
doc: |
  No magic; the layout is validated by consuming the file exactly (after
  GMMan's scrib-vecviz). u8 flags (low 6 bits == 2; 0x40 fixed-point points, 0x80
  bounds block); u16 xscale<<3, u16 yscale<<3 (stored >> 3 << 2); u16 groups; u8
  layers; u16 npoints; points (0x40: runs of {u16 n, u16 color, n * s16x2 /
  8196}.
seq:
  - id: flags
    type: u1
  - id: xscale_shifted
    type: u2
  - id: yscale_shifted
    type: u2
  - id: groups
    type: u2
  - id: layers
    type: u1
  - id: point_count
    type: u2
  - id: rest
    size-eos: true
