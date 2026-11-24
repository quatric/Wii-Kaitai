meta:
  id: gwb
  title: 'Ubisoft .gwb sound bank header (Monster 4x4: World Circuit)'
  file-extension: gwb
  endian: be
doc: |
  Small .gwb (< 0x2000 bytes) lists subsongs; the sibling .gwd holds headerless
  DSP-ADPCM. v6/v7 @+0, file id be32 @+1, subsong count be32 @+5 (v6) / +9 (v7),
  then per subsong: u8 flags (0x02 mono, 0x09/0x0a stereo), id be32, (v7: be32 2,
  stream offset, stream size, be32 5), then one 0x4a-byte record per channel
  {loop flag, rate, loop start/end/end/start nibbles, 0, then the 0x2e bytes of a
  standard DSP header from +0x1c}. v6 streams start at the channel's first
  nibble, v7 interleave 0x4000.
seq:
  - id: version
    type: u1
    doc: 6 or 7.
  - id: file_id
    type: u4
  - id: pad
    size: 4
    if: version == 7
  - id: subsong_count
    type: u4
  - id: rest
    size-eos: true
types:
  channel_record:
    seq:
      - id: loop_flag
        type: u4
      - id: rate
        type: u4
      - id: loop_nibbles
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: zero
        type: u4
      - id: dsp_part
        size: 0x2e
      - id: tail
        size: 0x4a - 0x04 - 0x04 - 0x10 - 0x04 - 0x2e
