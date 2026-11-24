meta:
  id: iois_str
  title: IO Interactive IOISNDSTREAM (.str)
  file-extension: str
  endian: le
doc: |
  IO Interactive `IOISNDSTREAM` sound stream (Mini Ninjas). The big `Wii_Def.str`
  holds the music/ambience, the per-language ones the dialogue. A 0x800-byte
  header is followed by the 0x800-aligned stream data.
seq:
  - id: magic
    contents: IOISNDSTREAM
  - id: version
    type: u4
    doc: 9.
  - id: timestamp
    type: u8
  - id: unknown
    type: u4
  - id: num_streams
    type: u4
