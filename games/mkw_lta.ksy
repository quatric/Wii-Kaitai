meta:
  id: mkw_lta
  endian: be
  title: Mario Kart Wii LE-CODE Track Archive (LTA)
doc: |
  LE-CODE Track Archive, per `lta_header_t` in lib-szs.h. Holds a
  slot node list; the extension string list was added in v2.41a and
  is only present when `head_size` covers it.

  The canonical magic is `LTR-ARCH`, major version is 1, all file and node
  offsets are 0x20-aligned, and total size is capped at 0x7fffffe0. The
  extension pair becomes valid only when the header includes both words
  (`head_size >= 0x2c`) and `ext_size` is non-zero. `head_size` therefore
  acts as a minor-version/layout boundary rather than merely padding.
seq:
  - id: magic
    contents: [0x4c, 0x54, 0x52, 0x2d, 0x41, 0x52, 0x43, 0x48]
  - id: version
    type: u4
    doc: Major format version; the published value is 1.
  - id: head_size
    type: u4
    doc: Header byte size and minor-layout discriminator.
  - id: file_size
    type: u4
    doc: Declared total archive length, normally 0x20-aligned.
  - id: node_offset
    type: u4
    doc: Absolute offset of the slot-node list.
  - id: node_size
    type: u4
    doc: Byte size of one slot node (`lta_node_t`).
  - id: base_slot
    type: u4
    doc: First logical slot represented by this archive.
  - id: num_slots
    type: u4
    doc: Number of slot nodes; LE-CODE limits node capacity to 0x2000.
  - id: ext_offset
    type: u4
    if: head_size >= 0x2c
    doc: Absolute offset of the extension-string list introduced in v2.41a.
  - id: ext_size
    type: u4
    if: head_size >= 0x2c
    doc: Byte length of that extension-string list; zero means absent.
instances:
  has_extension:
    value: head_size >= 0x2c and ext_size != 0
