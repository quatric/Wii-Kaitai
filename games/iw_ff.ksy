meta:
  id: iw_ff
  title: Infinity Ward / Treyarch fastfile (.ff)
  file-extension: ff
  endian: be
doc: |
  Infinity Ward / Treyarch fastfile (Call of Duty: World at War, Wii). One zlib
  stream (a few footer bytes behind it) inflates to the zone: a 0x30-byte header
  `{u32 size, u32 external size, u32 block sizes ...}`, the asset list and the
  assets.
seq:
  - id: magic
    contents: IWffu100
  - id: version
    type: u4
    doc: 0x19b.
  - id: zlib_stream
    size-eos: true
