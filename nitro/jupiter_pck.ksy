meta:
  id: jupiter_pck
  title: Jupiter Corp DS Model/Motion Package (.pck)
  file-extension: pck
  endian: le
doc: |
  Jupiter Corp's Nintendo DS Model/Motion Package (The World Ends with You,
  Kingdom Hearts Re:coded). The header is the member count and a table of
  member sizes; members are packed back to back after `header_length` and are
  Nitro 3D resources (`BMD0`, `BCA0`, `BTP0`, `BTX0`, `BTA0`, `BMA0`, `COLI`).

  A valid file satisfies `header_length + sum(sizes) == file size`, every size
  is non-zero, and each member starts with a four-character tag of `A-Z0-9`.
  The member offsets are implied: each member starts where the previous one
  ended.
seq:
  - id: header_length
    type: u4
    doc: Offset of the first member; at least `8 + 4 * count`.
  - id: count
    type: u4
    valid:
      min: 1
  - id: sizes
    type: u4
    repeat: expr
    repeat-expr: count
  - id: header_padding
    size: header_length - 8 - 4 * count
  - id: members
    type: member(_index)
    repeat: expr
    repeat-expr: count
types:
  member:
    params:
      - id: index
        type: s4
    seq:
      - id: data
        size: _root.sizes[index]
        type: resource
  resource:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: Four-character resource tag (`BMD0`, `BTX0`, ...).
      - id: body
        size-eos: true
