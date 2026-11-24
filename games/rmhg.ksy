meta:
  id: rmhg
  title: Grasshopper Manufacture RMHG resource container (.rsl)
  file-extension: rsl
  endian: le
doc: |
  Grasshopper Manufacture `RMHG` resource container (No More Heroes 1/2 `.rsl`).
  `kind`: 1 textures, 2 models, 3 group, 0xCD ... An entry holds either another
  RMHG or a leaf (GCT0 texture, GMF2 model, GAN2 animation, ...). The first
  entry's offset marks the end of the entry table. The entry's id word indexes the
  root container's name table (header word at +0x10 = offset of `{u32 count, u32
  offset of the u32 string offsets, u32 flags}`; strings are XOR 0x8D and end with
  0x8D when `flags & 1` and the build number exceeds 0x41B).
seq:
  - id: magic
    contents: RMHG
  - id: kind
    type: u4
  - id: header_size
    type: u4
    doc: 0x20.
  - id: build_number
    type: u4
  - id: name_table_offset
    type: u4
  - id: zeros
    size: 12
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: (first_offset - 0x20) / 0x20
instances:
  first_offset:
    pos: 0x20
    type: u4
types:
  entry:
    seq:
      - id: offset
        type: u4
        doc: From the container start.
      - id: len_data
        type: u4
      - id: nested
        type: u4
        doc: 1 when nested.
      - id: constant_0x427
        type: u4
      - id: id
        type: u4
      - id: zeros
        size: 12
