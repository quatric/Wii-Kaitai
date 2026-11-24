meta:
  id: agsc
  title: Retro Studios audio group (.agsc)
  file-extension: agsc
  endian: be
doc: |
  Metroid Prime / Prime 2. "Audi" or u32 1, a name string, size-prefixed
  chunks; the header chunk holds 0x20-byte entries {id, offset @4 into the
  data chunk, rate u16 @0xe, samples @0x10, loop start @0x14, loop length
  @0x18, coef offset @0x1c}, then 0xFFFFFFFF and 0x28-byte coefficient records.
seq:
  - id: marker
    size: 4
    doc: '"Audi" or u32 1.'
  - id: rest
    size-eos: true
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: unk8
        size: 6
      - id: rate
        type: u2
      - id: samples
        type: u4
      - id: loop_start
        type: u4
      - id: loop_length
        type: u4
      - id: coef_offset
        type: u4
