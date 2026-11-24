meta:
  id: ath_anm
  title: Athletics-engine animation (.ANM)
  file-extension: anm
  endian: be
doc: |
  Athletics-engine animation `.ANM` (International Athletics / Summer
  Athletics style "ath" engine, pairs with `.MSH` / `.TEX`, see `ath_tex`).
  Quaternions (4 floats x,y,z,w), positions (3 floats) and `frames * nodes`
  pairs `{u16 index, u16 flag}` (frame major) follow the header; the flag
  meaning is unresolved.
seq:
  - id: version
    type: u2
    doc: 0x0403.
  - id: len_rest
    type: u4
    doc: File size - 2.
  - id: node
    size: 32
    type: strz
    encoding: ASCII
  - id: num_frames
    type: u4
  - id: num_nodes
    type: u4
  - id: rate
    type: u4
  - id: len_quaternions
    type: u4
  - id: len_positions
    type: u4
  - id: quaternions
    size: len_quaternions
  - id: positions
    size: len_positions
  - id: frame_nodes
    type: frame_node
    repeat: expr
    repeat-expr: num_frames * num_nodes
types:
  frame_node:
    seq:
      - id: index
        type: u2
      - id: flag
        type: u2
