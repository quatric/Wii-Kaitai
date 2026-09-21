meta:
  id: rkc
  endian: be
  title: Mario Kart Wii RKC container (Riivolution/CTGP custom track container)
doc: |
  RKC container ("RKCT" + embedded "RKCO"), ported from `rkct_t`/
  `rkco_t` in lib-rkc.h. Wraps a YAZ0-compressed U8 archive
  (rkc.szs) at a fixed offset, not modeled further here.
seq:
  - id: magic
    contents: "RKCT"
  - id: size
    type: u4
  - id: u8_offset
    type: u4
    doc: Offset of the YAZ0-compressed U8 archive, usually 0x50.
  - id: version
    type: u4
    doc: Always 0x640.
  - id: rkco
    type: rkco_t
types:
  rkco_t:
    seq:
      - id: magic
        contents: "RKCO"
      - id: xdata
        size: 0x40 - 4
