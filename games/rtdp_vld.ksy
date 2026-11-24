meta:
  id: rtdp_vld
  title: Arc Rise Fantasia RTDP archive (.vld)
  file-extension: vld
  endian: be
doc: |
  Arc Rise Fantasia `*.vld` packs (`Btl/btl_*.vld`): a sequence of `RTDP`
  archives, each padded to 0x800. The archives must tile the whole file. Entry
  offsets are relative to the data start.
seq:
  - id: magic
    contents: RTDP
  - id: header_size
    type: u4
    doc: 0x100, the start of the data.
  - id: count
    type: u4
  - id: len_total
    type: u4
    doc: Header + data.
  - id: reserved
    size: 0x10
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: len_data
        type: u4
      - id: offset
        type: u4
