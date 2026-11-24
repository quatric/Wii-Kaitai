meta:
  id: mjbf_bft
  title: Monster Jam BigFile index (MJ.bft)
  file-extension: bft
  endian: be
doc: |
  Monster Jam: Path of Destruction `MJ.bft`. Siblings: `MJ.bff` (be32 count,
  be32 0, count be32 name lengths/offsets, then NUL-separated paths in index
  order), `MJ.bfd` (data) and `MJ.bfh` (name hashes). If bit 31 of an offset is
  set, the low bits point to `{be32 n, n * be32 offset}` inside this file: the
  file is stored n times (DVD seek optimisation) and the first copy is used.
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_data
        type: u4
