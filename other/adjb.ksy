meta:
  id: adjb
  file-extension: adjb
  endian: le
  title: Toys for Bob ADJB mesh-adjacency table
doc: |
  A small per-mesh table of index buffers (mesh adjacency data). A
  header count is followed by that many 8-byte records (mesh id, byte
  offset into the data area right after the table); each record's data
  area is a run of little-endian u16 vertex indices. The real extractor
  sizes each mesh's run by sorting all offsets and taking the gap to the
  next higher one (or EOF for the highest), to stay correct even when
  the table isn't offset-sorted; this .ksy assumes the common
  offset-ascending case and sizes each entry's `indices` by the next
  table row (or EOF for the last row).
seq:
  - id: num_meshes
    type: s4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_meshes
instances:
  data_start:
    value: 4 + num_meshes * 8
types:
  entry:
    seq:
      - id: mesh_id
        type: s4
      - id: ofs_data
        type: s4
        doc: Byte offset of this mesh's index run, relative to the end of the table.
    instances:
      abs_ofs:
        value: _root.data_start + ofs_data
      next_abs_ofs:
        value: |
          _index + 1 < _root.num_meshes
            ? _root.data_start + _root.entries[_index + 1].ofs_data
            : _root._io.size
      indices:
        io: _root._io
        pos: abs_ofs
        type: u2
        repeat: expr
        repeat-expr: (next_abs_ofs - abs_ofs) / 2
        doc: Vertex indices for this mesh, sized by the gap to the next entry (or EOF).
