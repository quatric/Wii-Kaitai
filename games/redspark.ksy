meta:
  id: redspark
  title: RedSpark audio (.rsd, after un-XOR)
  file-extension: rsd
  endian: be
doc: |
  MadWorld, Imabikisou. The header is XOR-"encrypted" with a rolling key
  ("RedSpark" after decryption): key0 = be32(buf) ^ "RedS"; every following
  32-bit word w is xored with key = rotl(key, 3) + key (the first word with key0
  itself, then key = rotl(key, 11)). This definition describes the DECRYPTED
  header: base header 0x30: +0x18 data offset, +0x1c bank flag, +0x1e type
  (0 = no audio), +0x20 data size. Stream: {rate @+0xc, frames @+0x10, channels
  @+0x1e, loop cues @+0x1f}, 8-byte channel configs, optional cue points, then
  per channel 0x2e bytes of DSP coefficients; ADPCM interleaved per 8-byte
  frame. A bank lists mono sounds (header table at +0x20) addressed from the data
  offset.
seq:
  - id: magic
    contents: RedSpark
  - id: unk8
    type: u4
  - id: rate
    type: u4
  - id: frames
    type: u4
  - id: unk14
    size: 4
  - id: data_offset
    type: u4
  - id: bank_flag
    type: u2
  - id: type
    type: u2
    doc: 0 = no audio.
  - id: data_size
    type: u4
  - id: rest
    size-eos: true
