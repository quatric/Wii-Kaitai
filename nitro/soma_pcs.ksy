meta:
  id: soma_pcs
  title: Monolith Soft PCS 2D animation/layout sequence (Soma Bringer .pcs)
  file-extension: pcs
  endian: le
doc: |
  `pcs\0` 2D layout / animation container of Soma Bringer (16 files). A
  header, an array of offsets to `pcn\0` components, each carrying keyframe
  tracks in Nintendo DS FX32 (20.12 fixed point, divide by 4096) format.

  Tracks: `pos`, `ang`, `sca` (16-byte keys: frame, x, y, z) and `col`
  (8-byte keys: frame, RGB555, alpha).

  Header variants: normally word 1 is the file size and word 2 the component
  count (1..256); a few files (e.g. `BFldItm.pcs`) hold the count in word 1
  with word 2 equal to 0. `component_count` follows nintoolbox's rule.
seq:
  - id: magic
    contents: ['pcs', 0]
  - id: word1
    type: u4
  - id: word2
    type: u4
  - id: unknown_0c
    type: u4
  - id: component_offsets
    type: u4
    repeat: expr
    repeat-expr: component_count
instances:
  component_count:
    value: 'word2 != 0 ? word2 : word1'
  components:
    pos: 0
    type: component_at(_index)
    repeat: expr
    repeat-expr: component_count
types:
  component_at:
    params:
      - id: index
        type: s4
    instances:
      body:
        pos: _root.component_offsets[index]
        type: component(_root.component_offsets[index])
        io: _root._io
  component:
    params:
      - id: start
        type: u4
    seq:
      - id: magic
        contents: ['pcn', 0]
      - id: unknown_04
        size: 12
      - id: size
        type: u4
      - id: unknown_14
        size: 10
      - id: num_tracks
        type: u2
        doc: Offset 0x1e of the component.
      - id: track_offsets
        type: u4
        repeat: expr
        repeat-expr: num_tracks
        doc: Relative to the start of the component.
    instances:
      tracks:
        type: track_at(start + track_offsets[_index])
        pos: 0
        repeat: expr
        repeat-expr: num_tracks
  track_at:
    params:
      - id: abs_offset
        type: u4
    instances:
      body:
        pos: abs_offset
        type: track
        io: _root._io
  track:
    seq:
      - id: tag
        type: strz
        size: 4
        encoding: ASCII
        doc: '`pos`, `ang`, `sca` or `col`.'
      - id: size
        type: u4
      - id: unknown_08
        type: u4
      - id: num_keys
        type: u4
      - id: vec_keys
        type: vec_key
        repeat: expr
        repeat-expr: num_keys
        if: tag != "col"
      - id: color_keys
        type: color_key
        repeat: expr
        repeat-expr: num_keys
        if: tag == "col"
  vec_key:
    seq:
      - id: frame_fx32
        type: s4
      - id: x_fx32
        type: s4
      - id: y_fx32
        type: s4
      - id: z_fx32
        type: s4
    instances:
      frame:
        value: frame_fx32 / 4096.0
  color_key:
    seq:
      - id: frame_fx32
        type: s4
      - id: rgb555
        type: u2
      - id: alpha
        type: u2
