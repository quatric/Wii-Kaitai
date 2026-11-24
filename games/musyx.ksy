meta:
  id: musyx
  title: Factor 5 MusyX sound bank (Wii .arc + .sam)
  file-extension: arc
  endian: be
doc: |
  Resident Evil 0. Big-endian chunk container {u32 0, u32 count, u32 0x20 table
  offset, ...} with 0x20-byte records {u32 offset, u32 size, char name[8], char
  type[16] ("pool", "proj", "sdir")}. The "sdir" chunk holds 0x20-byte entries
  {u32 id << 16, u32 sample byte offset into the .sam, u32 0, u8 pitch, u8 0,
  u16 rate, u32 (format << 24 | sample count), u32 loop start, u32 loop length,
  u32 offset of the ADPCM parameters}, terminated by 0xffffffff, then 0x28-byte
  ADPCM parameter blocks {u16 gain, u8 ps (+1 pad), s16 yn1, yn2, s16 coef[16]}.
seq:
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: table_offset
    type: u4
    doc: 0x20.
  - id: pad
    size: table_offset - 12
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: name
        size: 8
        type: strz
        encoding: ASCII
      - id: type
        size: 16
        type: strz
        encoding: ASCII
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
  sdir_entry:
    seq:
      - id: id_shifted
        type: u4
      - id: sample_offset
        type: u4
      - id: zero
        type: u4
      - id: pitch
        type: u1
      - id: zero2
        type: u1
      - id: rate
        type: u2
      - id: format_samples
        type: u4
      - id: loop_start
        type: u4
      - id: loop_length
        type: u4
      - id: adpcm_param_offset
        type: u4
  adpcm_params:
    seq:
      - id: gain
        type: u2
      - id: ps
        type: u1
      - id: pad
        type: u1
      - id: yn1
        type: s2
      - id: yn2
        type: s2
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
