meta:
  id: genki_lxmf
  title: Genki LXMF bundle (.LXMF)
  file-extension: lxmf
  endian: be
doc: |
  Genki `LXTools_FileCombine` self-contained bundle (Spectrobes: Origins:
  character models, effects, sound banks). The entry table starts at 0x40, or
  at 0x10 for the character motion files (`..._MOT.LXMF`, `version_word` 1).
  Members (BRRES, `REFF`, `PARAM.BIN`, nested `.LXMF`) follow back to back and
  the 0x40-byte path fields sit after them.
seq:
  - id: magic
    contents: FMXL
  - id: version_word
    type: u4
    doc: 0x01010100, or 1 for the character motion files.
  - id: num_members
    type: u4
instances:
  entries:
    pos: 'version_word == 1 ? 0x10 : 0x40'
    type: entry
    repeat: expr
    repeat-expr: num_members
types:
  entry:
    seq:
      - id: zero0
        type: u4
      - id: offset
        type: u4
      - id: zero1
        type: u4
      - id: len_padded
        type: u4
      - id: zero2
        type: u4
      - id: path_offset
        type: u4
      - id: len_path_field
        type: u4
        doc: 0x40.
      - id: len_data
        type: u4
    instances:
      path:
        pos: path_offset
        io: _root._io
        type: strz
        encoding: ASCII
      data:
        pos: offset
        io: _root._io
        size: len_data
