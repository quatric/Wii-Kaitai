meta:
  id: eabnk
  title: EA BNKb sound bank
  endian: be
doc: |
  Tiger Woods PGA Tour abnk_*.bin; "ABKC" banks (FIFA .abk) embed the same bank
  at +0x20. Each entry is an EA "PT" tag header (platform u16 LE at +2, then
  {tag, len, value} patches: 0xa0 codec 0x12 = GC DSP, 0x84 rate, 0x85 samples,
  0x88 absolute data offset, 0x8f 33 bytes with 16 DSP coefficients).
seq:
  - id: magic
    contents: BNKb
  - id: version
    type: u1
    doc: 4 or 5.
  - id: unk5
    type: u1
  - id: count
    type: u2
  - id: unk8
    size: 0x14 - 8
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Relative to their own slot (0 = unused).
