meta:
  id: sir0
  endian: le
  title: Pokemon Mystery Dungeon SIR0 resource container
doc: |
  Pokemon Mystery Dungeon "SIR0" resource container, per lib-sir0.c.
  Three segments: primary data (0x10 up to sub_header_offset),
  subheader (up to pointer_offsets_offset), and the pointer-offset
  table to the end of the file. The tail is a variable-length delta list
  of locations within the primary data that need pointer relocation,
  followed by 0xAA padding to a 16-byte boundary. The delta coding and
  game-specific pointer content are not decoded by nintoolbox and are
  not modeled here.

  The extractor accepts .sir0 and .bin files with SIR0 magic. It treats
  invalid or out-of-file subheader/pointer offsets as EOF when choosing
  extraction boundaries. It writes data.bin for a nonempty primary segment,
  subheader.bin only when its start and end are valid and nonempty, and
  pointers.bin when a pointer tail remains. These filenames are generated.

  The writer reconstructs the two offsets from the supplied segment sizes
  and copies pointers.bin verbatim, because its relocation list cannot be
  regenerated from data.bin alone. If pointers.bin is absent it writes
  16 zero bytes instead; this fallback is not the retail 0xAA padding
  convention. The writer zeros the word at 0x0c. Thus byte-exact retail
  reproduction requires preserving the original pointer-tail bytes.
seq:
  - id: magic
    contents: "SIR0"
  - id: sub_header_offset
    type: u4
    doc: Absolute start of the subheader and end of primary data.
  - id: pointer_offsets_offset
    type: u4
    doc: Absolute start of the pointer-delta tail and end of subheader.
  - id: unknown_0c
    type: u4
    doc: Usually 0.
instances:
  data_segment:
    pos: 0x10
    size: sub_header_offset - 0x10
    if: sub_header_offset >= 0x10
    doc: Primary payload; extractor writes it as data.bin when nonempty.
  sub_header_segment:
    pos: sub_header_offset
    size: pointer_offsets_offset - sub_header_offset
    if: pointer_offsets_offset >= sub_header_offset
    doc: Secondary payload; extractor writes it as subheader.bin when valid.
  pointer_offsets_segment:
    pos: pointer_offsets_offset
    size-eos: true
    doc: Opaque pointer-location delta list and trailing alignment bytes.
