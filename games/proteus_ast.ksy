meta:
  id: proteus_ast
  title: Proteus engine SDASSETF bundle (.ast)
  file-extension: ast
  endian: be
doc: Every BMAP chunk holds one GX texture (CMPR, RGBA8, or C4/C8 with an RGB5A3 CLUT child). I Spy / Goosebumps HorrorLand (Wii).
seq:
  - id: magic
    size: 8
    doc: '"SDASSETF".'
  - id: rest
    size-eos: true
