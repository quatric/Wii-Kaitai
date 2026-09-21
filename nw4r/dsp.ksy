meta:
  id: dsp
  file-extension: dsp
  endian: be
  title: Nintendo GameCube/Wii standalone DSP-ADPCM audio stream
doc: |
  The raw, headerless-container ".dsp" file used by GameCube-era tools to
  hold a single-channel DSP-ADPCM (Nintendo's "adpcm_thp") stream: a fixed
  0x60-byte big-endian header (sample count, loop info, the 16 s16 filter
  coefficients, and initial decoder history), followed immediately by
  8-byte ADPCM frames (14 4-bit samples each). Modeled from `IsDSP()` and
  `DecodeDSPToWAV()` in nintoolbox's lib-dsp.c.

  The actual codec math (frame decode/encode, coefficient derivation) lives
  in lib-dspadpcm.c/.h, which defines no on-disk file format of its own --
  it is pure decode/encode logic reused wherever DSP-ADPCM is embedded,
  including inside this file's frame data and inside NW4R containers like
  `nw4r/brstm.ksy` and `nw4r/rwav.ksy`. This .ksy models only the standalone
  .dsp file header/frame layout; it does not duplicate those containers'
  own embedded ADPCM-info structures.
seq:
  - id: num_samples
    type: u4
    doc: Total decoded sample count.
  - id: num_adpcm_nibbles
    type: u4
    doc: Not directly checked by IsDSP(), but part of the known .dsp header layout.
  - id: sample_rate
    type: u4
  - id: loop_flag
    type: u2
    doc: 0 = not looped, 1 = looped (only values IsDSP() accepts).
  - id: format
    type: u2
    doc: DSP-ADPCM format tag; IsDSP() only accepts 0 or 2.
  - id: loop_start_offset
    type: u4
  - id: loop_end_offset
    type: u4
  - id: current_address
    type: u4
  - id: coefs
    type: s2
    repeat: expr
    repeat-expr: 16
    doc: 8 pairs of Q11 predictor coefficients, read at offset 0x1c by DecodeDSPToWAV().
  - id: gain
    type: u2
  - id: initial_hist1
    type: s2
    doc: Initial decoder history sample 1, read at offset 0x40.
  - id: initial_hist2
    type: s2
    doc: Initial decoder history sample 2, read at offset 0x42.
  - id: loop_hist1
    type: s2
  - id: loop_hist2
    type: s2
  - id: reserved
    size: 22
    doc: Pads the header out to the fixed 0x60-byte size where ADPCM frame data begins.
  - id: frames
    type: frame
    repeat: eos
types:
  frame:
    doc: One 8-byte DSP-ADPCM frame -- a predictor/scale byte plus 14 4-bit samples.
    seq:
      - id: predictor_scale
        type: u1
      - id: nibbles
        size: 7
