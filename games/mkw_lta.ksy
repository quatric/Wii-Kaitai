meta:
  id: mkw_lta
  endian: be
  title: Mario Kart Wii LE-CODE Track Archive (LTA)
doc: |
  LE-CODE Track Archive, per `lta_header_t` in lib-szs.h. Holds a
  slot node list; the extension string list was added in v2.41a and
  is only present when `head_size` covers it.
seq:
  - id: magic
    contents: [0x4c, 0x54, 0x52, 0x2d, 0x41, 0x52, 0x43, 0x48]
  - id: version
    type: u4
  - id: head_size
    type: u4
  - id: file_size
    type: u4
  - id: node_offset
    type: u4
  - id: node_size
    type: u4
  - id: base_slot
    type: u4
  - id: num_slots
    type: u4
  - id: ext_offset
    type: u4
    if: head_size >= 0x2c
  - id: ext_size
    type: u4
    if: head_size >= 0x2c
instances:
  has_extension:
    value: head_size >= 0x2c and ext_size != 0
