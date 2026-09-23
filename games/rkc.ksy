meta:
  id: rkc
  endian: be
  title: Mario Kart Wii RKC container (Riivolution/CTGP custom track container)
doc: |
  RKC container ("RKCT" + embedded "RKCO"), ported from `rkct_t`/
  `rkco_t` in lib-rkc.h. Wraps a YAZ0-compressed U8 archive (named
  "rkc.szs" by the reference tool) starting at `u8_offset`, usually
  0x50 right after the fixed-size `rkco_t` record; that YAZ0/U8 stream
  itself is exposed here as raw bytes (see `u8.ksy` for the U8
  container shape once decompressed).
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
instances:
  u8_archive:
    pos: u8_offset
    size-eos: true
    doc: YAZ0-compressed U8 archive payload (rkc.szs), starting at `u8_offset`.
types:
  rkco_t:
    seq:
      - id: magic
        contents: "RKCO"
      - id: xdata
        size: 0x40 - 4
