meta:
  id: imagine_cam
  title: Imagine engine camera path (.cam)
  file-extension: cam
  endian: be
doc: |
  Imagine engine camera path `.cam` (Party Babyz cut scenes; usually inside the
  Imagine LZSS wrapper). Each key is a row-major 3x4 camera matrix: three rows
  `{x, y, z, translation}` of floats.
seq:
  - id: num_keys
    type: u4
  - id: keys
    type: key
    repeat: expr
    repeat-expr: num_keys
types:
  key:
    seq:
      - id: matrix
        type: f4
        repeat: expr
        repeat-expr: 12
