meta:
  id: stp
  title: Sonic stage object table (stgNNN_A.bin / _P0..P6.bin)
  endian: le
doc: |
  Sonic and the Secret Rings / Black Knight. Magics "STA1", "STP0".."STP6".
  The meaning of the individual words and parameter payloads is not decoded.
seq:
  - id: magic
    size: 4
  - id: object_count
    type: u4
  - id: param_entry_count
    type: u4
    doc: <= object_count.
  - id: param_bytes
    type: u4
  - id: objects
    type: object
    repeat: expr
    repeat-expr: object_count
  - id: param_headers
    type: param_header
    repeat: expr
    repeat-expr: param_entry_count
  - id: param_data
    size: param_bytes
    doc: Payloads back to back (sizes from the headers); a padded tail may follow.
types:
  object:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: zero
        type: f4
      - id: words
        type: u4
        repeat: expr
        repeat-expr: 7
        doc: Rotation (16.16-ish ints), type id, packed small fields.
      - id: object_index
        type: u4
  param_header:
    seq:
      - id: kind
        type: u2
      - id: size
        type: u2
      - id: zero
        type: u4
