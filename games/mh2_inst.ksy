meta:
  id: mh2_inst
  title: Rockstar Leeds entity placement list (Manhunt 2 .inst)
  file-extension: inst
  endian: be
doc: |
  Big endian on the Wii disc, little endian in the PC copy. {u32 entity count,
  u32 record size}, records back to back. A record: entity type string,
  instance name (each NUL then 'p'-padded to 4), position 3 x f32, rotation
  quaternion 4 x f32, class string, then parameters {u32 name hash, 4-byte type
  "flo"/"boo"/"int"/"str", value (4 bytes or padded string)} up to record end.
seq:
  - id: entity_count
    type: u4
  - id: record_size
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: entity_count
types:
  record:
    seq:
      - id: entity_type
        type: strz
        encoding: ASCII
      - id: pad0
        size: (-(entity_type.length + 1)) % 4
      - id: instance_name
        type: strz
        encoding: ASCII
      - id: pad1
        size: (-(instance_name.length + 1)) % 4
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: rotation
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: rest
        size: _root.record_size - (entity_type.length + 1 + ((-(entity_type.length + 1)) % 4)) - (instance_name.length + 1 + ((-(instance_name.length + 1)) % 4)) - 28
        doc: Class string and typed parameters.
