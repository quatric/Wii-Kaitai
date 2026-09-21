meta:
  id: rez
  endian: be
  title: Humongous/Cat Daddy Resource.rez (Backyard Football '10, Wii)
doc: |
  Humongous / Cat Daddy "Resource.rez" package, per lib-rez.h. The
  file has no header of its own -- everything is driven from a
  24-byte-slot footer table in the last 2048-byte sector. Group and
  resource slots share the same shape; a group's own resource table
  (name-only lookup) lives inline in the last `flags` bytes of its
  data and is not modeled here (only the flat slot table is).
  Per-resource-type payload layouts (texture, DSP-ADPCM sound, model
  tree, animation, skeletal motion) are extensively documented in
  the source but are variable-length, pointer-tagged trees rather
  than fixed records, and are left unmodeled.
seq:
  - id: sectors
    size-eos: true
instances:
  footer:
    pos: _io.size - 2048
    size: 2048
    type: footer_t
  slots:
    type: slot_t
    repeat: expr
    repeat-expr: footer.num_slots
    pos: _io.size - 2048 - (((footer.num_slots * 24 + 2047) / 2048) * 2048)
types:
  footer_t:
    seq:
      - id: unknown_00
        type: u4
      - id: first_slot
        type: u4
      - id: num_slots
        type: u4
  slot_t:
    doc: 24-byte slot entry. A "group" slot has flags >= 0x20.
    seq:
      - id: offset
        type: u4
        doc: Absolute file offset.
      - id: size
        type: u4
      - id: unpacked_size
        type: u4
      - id: kind
        type: s2
      - id: flags
        type: u2
        doc: Bit 0 = compressed (resource slots); >= 0x20 marks a group slot.
      - id: unknown_0c
        type: u4
      - id: set_tag
        type: u4
