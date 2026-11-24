meta:
  id: scumm_he
  title: Humongous Entertainment SCUMM HE blocks (.HE2 / .HE4 / resource file)
  endian: be
doc: |
  Block = {tag[4], u32 BE size incl. 8-byte header, payload}. ".he2": "TLKB"
  holding "TALK" blocks, each with an "HSHD" header (u16 0, u16 flags, u16
  0xffff, u16 LE sample rate, ...) and an "SDAT" block of unsigned 8-bit mono
  PCM. ".HE4": "SONG" with "SGHD" and one "SGEN" per song {u32 BE size 0x15,
  u32 LE id, u32 LE offset, u32 LE size, u8}, followed by "DIGI" blocks. The
  resource file "<GAME>.(a)" is XORed with 0x69 over the whole file first;
  decoded it is "LECF" > "LFLF" (per room) > resource blocks.
seq:
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: payload
        size: size - 8
  sgen:
    seq:
      - id: block_size
        type: u4
        doc: 0x15.
      - id: id
        type: u4le
      - id: offset
        type: u4le
      - id: size
        type: u4le
      - id: unk
        type: u1
