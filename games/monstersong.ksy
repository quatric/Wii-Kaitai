meta:
  id: monstersong
  title: Monster Games streamed music (.sng / .sn0, ExciteBots)
  file-extension: sng
  endian: le
doc: The audio is split with the .sf0 next to it. First blocks (2 channels x interleave bytes of big-endian PCM16) follow at 0x14.
seq:
  - id: sample_rate
    type: s4
    doc: 32000.
  - id: zero0
    type: u4
  - id: rest_size_per_channel
    type: u4
    doc: Size of the rest of every channel held in the .sf0.
  - id: interleave
    type: u4
  - id: zero1
    type: u4
  - id: data
    size-eos: true
