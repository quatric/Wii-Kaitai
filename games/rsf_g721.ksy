meta:
  id: rsf_g721
  title: Metroid Prime GameCube .rsf (G.721)
  file-extension: rsf
doc: |
  Headerless stereo CCITT G.721 (32 kbit/s) at 32000 Hz. The file is split into
  two halves (one per channel, interleave = (size + 1) / 2) of 4-bit codes, low
  nibble first.
seq:
  - id: codes
    size-eos: true
