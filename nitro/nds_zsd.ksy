meta:
  id: nds_zsd
  title: Dragon Booster DS audio (.zsd)
  file-extension: zsd
  endian: le
doc: PCM8 signed samples, interleaved per sample for stereo.
seq:
  - id: magic
    contents: ["ZSD", 0]
  - id: unk4
    size: 8
  - id: channels
    type: u4
  - id: rate
    type: u4
  - id: unk14
    size: 4
  - id: total_samples
    type: u4
    doc: All channels.
  - id: unk1c
    size: 4
  - id: data_offset
    type: u4
