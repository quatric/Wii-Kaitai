meta:
  id: rev
  endian: be
  title: Blitz Games Babel REV package (SpongeBob SquarePants, Wii)
doc: |
  Blitz Games "Babel" engine ".rev" package (Packages_Rev/*.rev,
  AudioRev/*.rev), recovered from the game's own ELF per lib-rev.h.
  Every offset is in units of `align`. Payloads are stored raw; the
  index is sorted by name CRC (MSB-first CRC32, poly 0x04C11DB7,
  init 0, no final XOR, over the lowercased name), so names (in the
  separate name pool, in file order) must be matched to entries by
  CRC rather than position.
seq:
  - id: id
    type: u4
  - id: align
    type: u4
    doc: 0x20 for packages, 0x800 for audio.
  - id: unknown_08
    type: u4
  - id: num_files
    type: u4
  - id: index_offset_units
    type: u4
    doc: In units of `align`.
  - id: unknown_14
    size: 0x28 - 0x14
  - id: names_offset_units
    type: u4
    doc: In units of `align`.
  - id: names_length
    type: u4
instances:
  index:
    type: index_entry
    repeat: expr
    repeat-expr: num_files
    pos: index_offset_units * align
  names:
    pos: names_offset_units * align
    size: names_length
    doc: NUL-separated name strings, in file order (not CRC order).
types:
  index_entry:
    seq:
      - id: offset_units
        type: u4
        doc: In units of the container's `align`.
      - id: name_crc
        type: u4
      - id: size
        type: u4
      - id: size2
        type: u4
      - id: unknown_10
        type: u4
        doc: Always 1.
      - id: unknown_14
        type: u4
        doc: Always 4.
      - id: file_time
        type: u8
