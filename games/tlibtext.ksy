meta:
  id: tlibtext
  title: Cabela's TLIB text library (.bkp)
  file-extension: bkp
  endian: le
doc: |
  "TLIBv1.0d". Header {u32 pool size, u32 string count, u32 table offset, ...},
  id/offset tables, then a pool of NUL-terminated UTF-16LE strings, each
  optionally preceded by a 16-bit id. Tables are not interpreted.
seq:
  - id: magic
    contents: TLIBv1.0d
  - id: pool_size
    type: u4
  - id: string_count
    type: u4
  - id: table_offset
    type: u4
  - id: rest
    size-eos: true
