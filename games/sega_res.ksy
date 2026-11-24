meta:
  id: sega_res
  title: SEGA resource container (Sakura Wars So Long My Love)
  file-extension: urs
  endian: le
doc: |
  URES, GDEN, SASN, AM?? movie packs, BS1 battle scenes, GFRD, LTHM. Members
  are chunks {magic, payload size @4, header size @8} (HMDL, HTEX, HMOT, HSPR,
  GRO3, ABDA, ABRS, UMDL, ...) spanning header + payload.
seq:
  - id: magic
    size: 4
    type: str
    encoding: ASCII
  - id: payload_size
    type: u4
  - id: header_size
    type: u4
  - id: flags
    type: u4
  - id: member_count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x1c.
  - id: pad
    size: table_offset - 0x18
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: member_count
    doc: 0 = absent.
types:
  member:
    seq:
      - id: magic
        size: 4
        type: str
        encoding: ASCII
      - id: payload_size
        type: u4
      - id: header_size
        type: u4
      - id: rest
        size: header_size + payload_size - 12
