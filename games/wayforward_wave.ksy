meta:
  id: wayforward_wave
  title: WayForward EngineBlack wave
  file-extension: wave
  endian: be
doc: |
  Magic "VAW3", "WWAV", 0xE5B7ECFE or 0xC9FB0C03 (DS). Defined big endian;
  LE variants need swapped fields. Codec 0 PCM8, 1 PCM16 BE, 2 DSP-ADPCM,
  3 IMA.
seq:
  - id: magic
    size: 4
  - id: version
    type: u4
  - id: file_size
    type: u4
  - id: rate
    type: f4
  - id: samples
    type: u4
  - id: loop_start
    type: u4
  - id: loop_end
    type: u4
  - id: codec
    type: u1
  - id: channels
    type: u1
  - id: unk1e
    size: 2
  - id: data_start
    type: u4
  - id: interleave
    type: u4
  - id: extra_data
    type: u4
    doc: Always 0x2c.
