meta:
  id: mh2_grf
  title: Rockstar Leeds AI navigation graph (Manhunt 2)
  file-extension: grf
  endian: be
doc: |
  "AING", version 1, node count, then variable-size node records: NUL-terminated
  name padded with 'p' to 4, u32 layer, position 3 x f32, radius f32, tag string
  (same padding) and link lists (not decoded; records have no fixed size).
seq:
  - id: magic
    contents: AING
  - id: version
    type: u4
  - id: node_count
    type: u4
  - id: nodes
    size-eos: true
types:
  node_head:
    seq:
      - id: name
        type: strz
        encoding: ASCII
      - id: name_pad
        size: (-(name.length + 1)) % 4
      - id: layer
        type: u4
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: radius
        type: f4
