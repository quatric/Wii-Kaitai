meta:
  id: sega_msb_ops
  title: Sakura Wars script instruction table (from main.dol)
  endian: be
doc: |
  28-byte records {u16 opcode, u16 flags, u32 argument count, 3 x u32 0, char
  *name} read from the descriptor tables of the game's main.dol; 337 instructions
  of the core language (0x15..0x77), the Plane/Effect/Action/Camera modules
  (0x1000..0x2f81) and the slg* battle calls (0x4000..0x4220). Used by sega_msb to
  name code words.
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: opcode
        type: u2
      - id: flags
        type: u2
      - id: argument_count
        type: u4
      - id: zero
        size: 12
      - id: name_ptr
        type: u4
