meta:
  id: slam_chunks
  title: Slam Games engine bank (SLAM AD audio / SLAM TD texture)
  file-extension: atd
  endian: le
doc: |
  `.atd` / `.sad` ("SLAM AD", audio, one AUDO chunk per sound) and `.std`
  ("SLAM TD", textures, one IMAG chunk per image) share this 16-byte head and
  chunk list; the first chunk is "DFTR" (a FILETIME). IMAG payload starts
  {u16 width, u16 height, u32 0, u16 format, u16 7, u32 0, u32 PGF size,...}.
seq:
  - id: magic
    size: 8
    doc: '"SLAM AD\0" or "SLAM TD\0".'
  - id: version
    type: u4
    doc: 0x30000.
  - id: four
    type: u4
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
      - id: size
        type: u4
      - id: payload
        size: size
