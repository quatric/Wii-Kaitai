meta:
  id: coresoft_nwtx
  title: Coresoft NWTX texture (.wtx)
  file-extension: wtx
  endian: be
doc: |
  Coresoft `NWTX` texture (Fantasy Aquarium World; members of JPack archives,
  see `coresoft_jpack`). Pixel data starts at 0x20: the base level first, then
  the mip chain.
seq:
  - id: magic
    contents: NWTX
  - id: format
    type: u4
    enum: format
  - id: width
    type: u4
  - id: height
    type: u4
  - id: num_mips
    type: u4
  - id: len_base_level
    type: u4
  - id: reserved
    size: 8
  - id: pixels
    size-eos: true
enums:
  format:
    1: cmpr
    2: i8
    3: rgb5a3
