meta:
  id: rwsdsp
  title: RenderWare Audio stream (.rws, GameCube/Wii ADPCM)
  file-extension: rws
  endian: le
doc: |
  Spyro Dawn of the Dragon. Chunk tree {u32 type, u32 size, u32 0x1c020065}: a
  0x80d container with a 0x80e header and a 0x80f data chunk. The header (BE
  fields) holds a 0x20-byte segment record per sub-stream at payload + 0x60 (u32
  count @ +0x20, {size, offset} in the last two words) and, in front of the text
  "00: GCN ADPCM Header", a DSP-like block: u32 interleave @ -52, u32 rate @ -44,
  u8 channels @ -31, 16 byte id, u32 samples, u32 nibbles, 16 coefficient
  shorts. Coefficients are shared by every segment.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: type
        type: u4
      - id: size
        type: u4
      - id: version
        type: u4
      - id: body
        size: size
