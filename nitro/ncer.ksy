meta:
  id: ncer
  endian: le
  title: Nintendo DS "Nitro" cell bank (NCER)
doc: |
  Nintendo DS NCER ("RECN") cell-bank container, as read by ScanNCER()
  in lib-ncer.c. Outer "RECN" header wraps one "KBEC" chunk holding a
  table of cells (each a small OAM group descriptor) followed by the
  packed OAM object records those cells index into. Object records are
  plain 6-byte DS hardware OAM attribute triples (attr0/attr1/attr2).
seq:
  - id: magic
    contents: "RECN"
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: n_sections
    type: u2
  - id: kbec
    type: kbec_chunk
    size: file_size - 0x10
types:
  kbec_chunk:
    seq:
      - id: magic
        contents: "KBEC"
      - id: chunk_size
        type: u4
      - id: n_cells
        type: u2
      - id: entry_kind
        type: u2
        doc: 0 -> 8-byte cell records, 1 -> 16-byte cell records (with bbox).
      - id: cell_table_off
        type: u4
        doc: Relative to this chunk's start (add 8 per ScanNCER).
      - id: mapping_mode
        type: u4
        if: chunk_size >= 20
        doc: |
          0-3: 1D mapping with that boundary shift; 4: 2D sheet mapping
          (RenderNCERCell()'s interpretation).
    instances:
      cell_size:
        value: 'entry_kind == 0 ? 8 : entry_kind == 1 ? 16 : 0'
      cells:
        type: cell(entry_kind)
        repeat: expr
        repeat-expr: n_cells
        pos: cell_table_off + 8
  cell:
    params:
      - id: entry_kind
        type: u2
    seq:
      - id: n_objects
        type: u2
      - id: read_only
        type: u2
        doc: Unused by the reference decoder.
      - id: object_off
        type: u4
        doc: Byte offset into the object table (relative to its start).
      - id: bbox
        type: s2
        repeat: expr
        repeat-expr: 4
        if: entry_kind == 1
        doc: Present only for 16-byte cell records (x0,y0,x1,y1 bounds).
  oam_object:
    doc: One 6-byte DS hardware OAM attribute record (attr0/attr1/attr2).
    seq:
      - id: attr0
        type: u2
      - id: attr1
        type: u2
      - id: attr2
        type: u2
