meta:
  id: rhgroove
  title: Rhythm Heaven Groove (Switch) assets
  endian: le
doc: |
  .cwv DPCM sound -> WAV (PCM16, loop in 'smpl'), .wmb tempo map, .tex (zstd)
  texture atlas, .spr sprite set. Each is validated by its footer / trailer /
  header; field layouts are in the nintoolbox rhgroove handler.
seq:
  - id: data
    size-eos: true
