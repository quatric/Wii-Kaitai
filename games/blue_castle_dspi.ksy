meta:
  id: blue_castle_dspi
  title: Blue Castle .dspi multi-channel DSP-ADPCM audio
  file-extension: dspi
  endian: be
doc: |
  `.dspi` audio members of Blue Castle's `.big` archives (The Bigs): one
  standard 0x60-byte GameCube DSP header per channel back to back, then each
  channel's ADPCM data, padded to 8 bytes (the last channel is stored
  unpadded). The headers of a channel set are identical apart from the
  coefficients and history.

  4264 such members across the audio archives of The Bigs (3708 stereo, 556
  mono) match this size rule exactly. The channel count is not stored: derive
  it from the file size using the per-channel byte count implied by
  `nibble_count`.
seq:
  - id: first_header
    type: dsp_header
  - id: rest
    size-eos: true
    doc: |
      Remaining channel headers (0x60 bytes each) and then the ADPCM data of every
      channel. For N channels the headers occupy `N * 0x60` bytes.
types:
  dsp_header:
    seq:
      - id: num_samples
        type: u4
      - id: num_nibbles
        type: u4
      - id: sample_rate
        type: u4
      - id: loop_flag
        type: u2
      - id: format
        type: u2
        doc: 0 = ADPCM.
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: current_address
        type: u4
      - id: coefs
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
      - id: initial_ps
        type: u2
      - id: initial_hist1
        type: s2
      - id: initial_hist2
        type: s2
      - id: loop_ps
        type: u2
      - id: loop_hist1
        type: s2
      - id: loop_hist2
        type: s2
      - id: pad
        size: 22
