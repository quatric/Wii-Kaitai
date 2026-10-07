meta:
  id: cing_wpf
  title: CiNG Wish Pack File (.wpf)
  file-extension: wpf
  endian: le
doc: |
  CiNG's Wish Pack File, used by Hotel Dusk: Room 215 / Last Window (Wish
  Room) on Nintendo DS. It has no magic number and no count: it is a chain of
  members, each a 32-byte header followed immediately by its payload, with
  the header's last word giving the offset of the next header. The chain ends
  when the next offset reaches the end of the file.

  Member names are 24-byte NUL-padded ASCII/Latin-1, conventionally prefixed
  with a backslash (names such as `07-04L.bin` and `dusk.bin` follow it).
  Padding to a 16-byte boundary follows each payload, which is why `next_offset` is stored rather
  than derived from `size`.
seq:
  - id: members
    type: member
    repeat: eos
types:
  member:
    seq:
      - id: name
        type: strz
        size: 24
        encoding: ISO-8859-1
      - id: size
        type: u4
        doc: Uncompressed payload length.
      - id: next_offset
        type: u4
        doc: Absolute offset of the next member header.
      - id: payload
        size: size
      - id: padding
        size: next_offset - _io.pos
        doc: |
          Alignment padding between the end of the payload and `next_offset`
          (nintoolbox requires `next_offset >= offset + 0x20 + size`).
