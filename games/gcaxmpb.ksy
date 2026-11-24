meta:
  id: gcaxmpb
  title: Marvelous gcax sound bank (.mpb / .mlt)
  endian: be
doc: |
  Chunks {tag[8], u64 payload size}. "gcaxMLT " wraps "gcaxMPB " (+ "gcaxMSB ");
  "gcaxMPB " holds "gcaxMPBW" (DSP-ADPCM wave data, mono) then "gcaxMPBP"
  (parameters): 0x20-byte header, then 0x50-byte wave records.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 8
        type: str
        encoding: ASCII
      - id: size
        type: u8
      - id: body
        size: size
  wave_record:
    seq:
      - id: samples
        type: u4
      - id: nibbles
        type: u4
      - id: rate
        type: u4
      - id: loop_flag
        type: u2
      - id: format
        type: u2
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: loop_current
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: hist1
        type: s2
      - id: hist2
        type: s2
      - id: loop_ps
        type: u2
      - id: loop_hist1
        type: s2
      - id: loop_hist2
        type: s2
      - id: pad
        size: 2
      - id: wave_offset
        type: u4
