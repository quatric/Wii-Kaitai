meta:
  id: sonic_one
  title: Sonic Team ONE archive (.one, .onz)
  file-extension: one
  endian: le
doc: |
  Sonic Team `ONE` archive (Sonic Unleashed, Wii `one_wii*/.../*.onz`; the whole
  `.onz` file is one Nintendo LZ11 stream, the nested `*.one` archives are the
  same layout uncompressed). The first payload starts right after the table;
  payloads are 0x20 aligned and hold GVR textures, `gncp` scene data and similar.
seq:
  - id: magic
    contents: 'one.'
  - id: num_entries
    type: u1
  - id: zeros
    size: 3
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        size: 0x38
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: len_data
        type: u4
    instances:
      data:
        pos: offset
        io: _root._io
        size: len_data
