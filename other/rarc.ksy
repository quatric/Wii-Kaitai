meta:
  id: rarc
  endian: be
  title: Nintendo RARC archive (GameCube/Wii)
doc: |
  Nintendo "RARC" directory archive, ported from `rarc_file_header_t`/
  `rarc_header_t`/`rarc_node_t`/`rarc_entry_t` in lib-rarc.h.
  Reference: http://hitmen.c02.at/files/yagcd/yagcd/chap15.html#sec15.3
seq:
  - id: magic
    contents: "RARC"
  - id: file_size
    type: u4
  - id: header_off
    type: u4
  - id: header_size
    type: u4
  - id: unknown1
    size: 16
  - id: header
    type: header_t
    size: header_size
types:
  header_t:
    seq:
      - id: num_nodes
        type: u4
      - id: root_off
        type: u4
      - id: num_entries
        type: u4
      - id: entry_off
        type: u4
      - id: str_pool_size
        type: u4
      - id: str_pool_off
        type: u4
      - id: unknown_18
        type: u2
      - id: unknown_1a
        type: u2
      - id: unknown_1c
        type: u4
    instances:
      nodes:
        type: node_t
        repeat: expr
        repeat-expr: num_nodes
        pos: root_off
        io: _io
      entries:
        type: entry_t
        repeat: expr
        repeat-expr: num_entries
        pos: entry_off
        io: _io
      string_pool:
        pos: str_pool_off
        size: str_pool_size
        io: _io
  node_t:
    seq:
      - id: name
        size: 4
      - id: name_off
        type: u4
      - id: unknown_08
        type: u2
      - id: num_entries
        type: u2
      - id: entry_index
        type: u4
  entry_t:
    seq:
      - id: id
        type: u2
        doc: File index, or 0xffff for a directory.
      - id: unknown_02
        type: u2
      - id: unknown_04
        type: u2
        doc: Possibly file mode (0200 dir, 1100 plain file).
      - id: name_off
        type: u2
      - id: data_off
        type: u4
        doc: File data offset, or directory node index.
      - id: data_size
        type: u4
      - id: unknown_10
        type: u4
