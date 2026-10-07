meta:
  id: wsi
  title: Eden Games / Ubisoft .wsi blocked DSP-ADPCM stream
  file-extension: wsi
  endian: be
doc: |
  Blocked DSP-ADPCM streams (Alone in the Dark and Aladdin Magic Racer, Wii;
  Eden Games / Ubisoft), as documented by vgmstream's `meta/wsi.c` and
  `layout/blocked_wsi.c` and re-derived against retail files.

  A run of blocks starts at `start`; blocks come `channels` at a time with
  channel 1 first. Each block is a 16-byte header followed by ADPCM frames
  (8 bytes = 14 samples each). In the first block of each channel the payload
  opens with that channel's own standard 0x60-byte GameCube DSP header (sample
  count, nibble count, rate, loop, coefficients, history); the frames
  follow it. nintoolbox concatenates each channel back into one plain `.dsp`.
seq:
  - id: start
    type: u4
    doc: Offset of the first block (0x20 in every sample).
  - id: channels
    type: u4
    doc: 2 in every sample.
  - id: pad
    size: start - 8
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: block_size
        type: u4
        doc: Same for every channel of a set; counts the whole block including this header.
      - id: unknown_04
        type: u4
        doc: Always 1.
      - id: channel
        type: u4
        doc: 1-based, alternating 1, 2, 1, 2, ...
      - id: unknown_0c
        type: u4
        doc: Always 0.
      - id: data
        size: block_size - 16
        doc: ADPCM frames, preceded by a 0x60-byte DSP header in each channel's first block.
