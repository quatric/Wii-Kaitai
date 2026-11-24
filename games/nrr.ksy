meta:
  id: nrr
  title: Switch 2 NRR0 module-hash list (.nrr)
  file-extension: nrr
  endian: le
doc: |
  'NRR0', a signed header, then a table {u32 hash_offset, u32 count, u64 0}
  followed by `count` SHA-256 digests of the .nro files the title may load. The
  table sits right after the signature area; found by checking each 16-byte slot
  for {offset == slot + 0x10, count that fits, zero tail}.
seq:
  - id: magic
    contents: NRR0
  - id: rest
    size-eos: true
types:
  table:
    seq:
      - id: hash_offset
        type: u4
      - id: count
        type: u4
      - id: zero
        type: u8
  digest:
    seq:
      - id: sha256
        size: 32
