meta:
  id: genki_lxhd
  title: Genki LXTools FileCombine header (.LXHD)
  file-extension: lxhd
  endian: be
doc: |
  Genki `LXTools_FileCombine` header file (Spectrobes: Origins `DATA.LXHD`,
  data in `DATA.LXBD`). A compressed member (flags 0x10000) is stored in the
  `.LXBD` as `RPCL`, u32 1, `LLZ7`, u32 inflated size, 16 zero bytes and a
  Nintendo LZ11 stream from +0x20.
seq:
  - id: magic
    contents: FMXL
  - id: version
    type: u4
    doc: 2.
  - id: num_files
    type: u4
  - id: header_rest
    size: 0x34
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: flags
        type: u4
        doc: 0x10000 = compressed, 0 = raw.
      - id: len_padded
        type: u4
      - id: zero0
        type: u4
      - id: offset
        type: u4
        doc: Into the .LXBD.
      - id: zero1
        type: u4
      - id: path_offset
        type: u4
        doc: Into this header file.
      - id: len_inflated
        type: u4
      - id: len_stored
        type: u4
    instances:
      path:
        pos: path_offset
        io: _root._io
        type: strz
        encoding: ASCII
