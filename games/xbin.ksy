meta:
  id: xbin
  title: HAL Laboratory XData (XBIN)
  endian: le
doc: |
  Header HAL's HEL engine puts on almost every non-asset file (Kirby Return to
  Dream Land, Star Allies, Forgotten Land). The header is 0x10 bytes, or 0x14
  when an RLOC offset follows (XData major > 2); a u32 at 0xc equals 65001. Two
  payloads have a generic layout: "YAML" (binary YAML, versions 2..6; v5+
  offsets are self-relative) and "FDGH"/"HGDF" scene preload graphs (versions
  2..3). Other payloads are game-specific tables.
seq:
  - id: magic
    contents: XBIN
  - id: unk4
    type: u4
  - id: unk8
    type: u4
  - id: codepage
    type: u4
    doc: 65001.
  - id: rest
    size-eos: true
