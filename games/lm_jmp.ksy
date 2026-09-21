meta:
  id: lm_jmp
  application: Luigi's Mansion (GameCube)
  endian: be
doc: |
  Luigi's Mansion (GameCube) JMP parameter table. Ported from the JMP
  half of lib-lmdata.c/.h (re-implemented from KillzXGaming/MdlConverter's
  GCNLibrary/LM JMP_Parser/JMPHashHelper, MIT-licensed). Header {u32
  records, u32 fields, u32 record_off, u32 record_size}, then one field
  descriptor per field {u32 name_hash, u32 bitmask, u16 offset, s8 shift,
  u8 type}, then `records` fixed-size raw records. Field names are not
  stored -- only their (recoverable) hash -- so record contents are left
  as opaque bytes here; use each field's `offset`/`bitmask`/`shift`/
  `type` to decode a value.

  This project's scanner also accepts the reverse byte order (detected
  structurally); this definition only covers the big-endian case, which
  is the one actually seen on-disc.

  lib-lmdata.h documents four sibling GameCube data formats sharing this
  provenance but with unrelated binary layouts -- KEY (skeletal
  animation), TMB (fade-effect timing), GEB (sprite data) and SLS (morph
  data) -- which are not modeled by this .ksy.
seq:
  - id: num_records
    type: u4
  - id: num_fields
    type: u4
  - id: record_off
    type: u4
  - id: record_size
    type: u4
instances:
  fields:
    pos: 16
    type: field
    repeat: expr
    repeat-expr: num_fields
  records:
    pos: record_off
    size: record_size
    repeat: expr
    repeat-expr: num_records
types:
  field:
    seq:
      - id: name_hash
        type: u4
        doc: Hash of the field name; resolved via a known-name table by the reference tool.
      - id: bitmask
        type: u4
      - id: offset
        type: u2
        doc: Byte offset of this field within a record.
      - id: shift
        type: s1
        doc: Bit shift applied to integer field types.
      - id: field_type
        type: u1
        enum: jmp_field_type
enums:
  jmp_field_type:
    0: int32
    1: string
    2: float
    4: int16
    5: byte
    6: shift_jis_string
