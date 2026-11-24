meta:
  id: brstm_stream
  title: Nintendo NW4R/NW4F/NW4C streams (BRSTM / BFSTM / BCSTM)
  endian: be
doc: |
  "RSTM" (Wii), "FSTM" (Wii U / Switch), "CSTM" (3DS). Chunked: header
  {magic, u16 BOM, u16 header size, u32 version, u32 file size, u16 block count},
  block refs, then INFO / SEEK / DATA. See nw4r/brstm.ksy for the Wii layout.
seq:
  - id: magic
    size: 4
  - id: bom
    type: u2
  - id: header_size
    type: u2
  - id: version
    type: u4
  - id: file_size
    type: u4
  - id: rest
    size-eos: true
