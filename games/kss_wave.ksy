meta:
  id: kss_wave
  title: KSS Wave Link Data (Konami sound, MLB Power Pros WaveData.bin)
  file-extension: bin
  endian: be
doc: |
  0x00 "KSS Wave Link Data  <date>", 0x24 u32 file size, 0x4c 16-byte bank
  records {u32 region table offset, data offset, data size, (id << 16) | 1},
  ended by a record whose low half is not 1; at 0x1044 + 8 * (bank + 1) u32
  offset of the bank's sample descriptors (0x40 each); region tables hold
  12-byte entries {u32 sample start, (tune << 16) | 0x7f00, 0x1f14}. Descriptor:
  DSP header from +0x0c {u16 loop flag, u16 format, u32 loop start, end, current,
  s16 coefs[16], gain, initial ps, 2 history, loop ps, 2 loop history, pad}.
seq:
  - id: banner
    size: 0x24
  - id: file_size
    type: u4
  - id: unk28
    size: 0x4c - 0x28
  - id: banks
    type: bank
    repeat: until
    repeat-until: (_.id_flag & 0xffff) != 1
types:
  bank:
    seq:
      - id: region_table_offset
        type: u4
      - id: data_offset
        type: u4
      - id: data_size
        type: u4
      - id: id_flag
        type: u4
        doc: (id << 16) | 1.
  descriptor:
    seq:
      - id: unk
        size: 0x0c
      - id: loop_flag
        type: u2
      - id: format
        type: u2
      - id: loop_start
        type: u4
      - id: end
        type: u4
      - id: current
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: hist
        type: s2
        repeat: expr
        repeat-expr: 2
      - id: loop_ps
        type: u2
      - id: loop_hist
        type: s2
        repeat: expr
        repeat-expr: 2
