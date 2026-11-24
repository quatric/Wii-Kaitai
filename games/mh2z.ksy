meta:
  id: mh2z
  title: Manhunt 2 MH2Z wrapper
  endian: be
doc: |
  Manhunt 2 (Wii) `MH2Z` wrapper (`.txd`, `.bsp`, `.dff`, `.ifp`): one zlib
  stream. The unpacked file is a TXD texture dictionary, a `WRLD` world, a
  `CLMP` model or an IFP animation.
seq:
  - id: magic
    contents: MH2Z
  - id: len_unpacked
    type: u4
  - id: zlib_stream
    size-eos: true
