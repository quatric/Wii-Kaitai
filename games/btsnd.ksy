meta:
  id: btsnd
  title: Wii U boot sound (.btsnd)
  file-extension: btsnd
  endian: be
doc: |
  Wii U boot sound: a type (0 or 2), the loop start, then 48 kHz stereo PCM16
  big-endian interleaved per sample (after vgmstream `btsnd.c`).
seq:
  - id: type
    type: u4
  - id: loop_start
    type: u4
  - id: pcm16_stereo
    size-eos: true
