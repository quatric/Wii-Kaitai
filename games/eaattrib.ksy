meta:
  id: eaattrib
  title: EA Attrib vault (.vlt, 64-bit keys)
  file-extension: vlt
  endian: be
doc: |
  EA Playground / Celebrity Sports Showdown engine, FIFA 10-15, EA Sports Active,
  Skate It, NHL Slapshot. The .vlt is a chunk list ({tag, u32 BE size including
  the 8-byte header}): Vers, StrN, DepN (u64 count, count u64 name hashes, count
  u32 name offsets, names "db.vlt", "db.bin"), DatN (the records), ExpN (u64
  count, then {u64 id, u64 type, u32 size, u32 offset} per export), PtrN
  (16-byte fix-ups {u32 location, u16 kind, u16 file, u64 target}; kind 2 selects
  the file the following locations are in, 3 = pointer at location -> target
  offset in `file`, 0 ends; file 0 = .vlt, 1 = .bin). Keys are Jenkins lookup8
  (level 0xABCDEF0011223344). ClassLoadData {u64 key, u32 collection count, u32
  field count, ptr fields}; fields 24 bytes {u64 key, u64 type, u32 size, u16
  count, u8 flags (bit 0 array), u8 log2 alignment}. CollectionLoadData {u64 key,
  class, parent, u32 reserve, shift, entry count, u16 type count x2, u64 layout,
  u64 type keys[], entries {u64 field, u32 value, u16 type index, u16 flags
  (0x4000 inline)}}. Arrays {u16 count, capacity, element size, pad} + elements.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size - 8
  expn:
    seq:
      - id: count
        type: u8
      - id: exports
        type: export
        repeat: expr
        repeat-expr: count
  export:
    seq:
      - id: id
        type: u8
      - id: type
        type: u8
      - id: size
        type: u4
      - id: offset
        type: u4
  ptrn_fixup:
    seq:
      - id: location
        type: u4
      - id: kind
        type: u2
      - id: file
        type: u2
      - id: target
        type: u8
  class_field:
    seq:
      - id: key
        type: u8
      - id: type
        type: u8
      - id: size
        type: u4
      - id: count
        type: u2
      - id: flags
        type: u1
      - id: log2_alignment
        type: u1
