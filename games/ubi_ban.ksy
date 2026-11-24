meta:
  id: ubi_ban
  title: Ubisoft/Kuju .BAN animation clip (Sleepover Party)
  file-extension: ban
  endian: le
doc: Bone record stride is 0x4c or 0x50 depending on the clip; key data is packed and not decoded.
seq:
  - id: duration
    type: f4
  - id: unk4
    size: 4
  - id: name
    size: 0x40
    type: strz
    encoding: ASCII
  - id: unk48
    type: f4
  - id: bone_count
    type: u4
  - id: rest
    size-eos: true
types:
  bone:
    seq:
      - id: zero
        type: u4
      - id: one
        type: u4
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: words
        size-eos: true
