meta:
  id: sega_gro3
  title: SEGA GRO3 model container (Sakura Wars So Long My Love)
  file-extension: gro3
  endian: le
doc: |
  Chunk container (G3MD, HMDL/KFMD ...). KFMD mesh data is a PlayStation-2
  style VIF packet stream: per strip UNPACK V4-32 (3 x f32 position + flag
  word), V3-32 (normals s32 / 32768), S-8 (one byte per vertex), V2-16
  (texcoords / 4096), all with the same vertex count.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: payload_size
        type: u4
      - id: header_size
        type: u4
      - id: zero
        type: u4
      - id: rest
        size: header_size + payload_size - 16
