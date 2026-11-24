meta:
  id: ubisb
  title: Ubisoft sound bank (.sb7, Red Steel)
  file-extension: sb7
  endian: be
doc: |
  After vgmstream ubi_sb. Section 1 has 0x68-byte entries at 0x1c, then 0x6c-byte
  resource headers, the extra section, the subblock table ({id, size}, 8 bytes)
  and the sounds. Resource header fields (type 1): stream size @8, extra offset
  @0xc, stream offset @0x10, streamed @0x28, loop @0x30, samples @0x3c, rate
  @0x50, channels @0x58, stream type @0x5c.
seq:
  - id: version
    type: u4
    doc: 0x00180006-8.
  - id: section1_count
    type: u4
  - id: resource_count
    type: u4
  - id: subblock_count
    type: u4
  - id: extra_size
    type: u4
  - id: flags
    type: u4
    repeat: expr
    repeat-expr: 2
  - id: section1
    size: 0x68
    repeat: expr
    repeat-expr: section1_count
  - id: resources
    type: resource
    repeat: expr
    repeat-expr: resource_count
  - id: extra
    size: extra_size
  - id: subblocks
    type: subblock
    repeat: expr
    repeat-expr: subblock_count
types:
  resource:
    seq:
      - id: type
        type: u4
      - id: unk4
        type: u4
      - id: stream_size
        type: u4
      - id: extra_offset
        type: u4
      - id: stream_offset
        type: u4
      - id: unk14
        size: 0x28 - 0x14
      - id: streamed
        type: u4
      - id: software
        type: u4
      - id: loop
        type: u4
      - id: unk34
        size: 8
      - id: samples
        type: u4
      - id: unk40
        size: 4
      - id: samples2
        type: u4
      - id: unk48
        size: 8
      - id: rate
        type: u4
      - id: unk54
        size: 4
      - id: channels
        type: u4
      - id: stream_type
        type: u4
      - id: tail
        size: 0x6c - 0x60
  subblock:
    seq:
      - id: id
        type: u4
      - id: size
        type: u4
