meta:
  id: ertmtex
  title: Telltale .d3dtx texture (Wii TPL in ERTM)
  file-extension: d3dtx
  endian: le
doc: '"ERTM" metastream (version 4+) whose D3DTX body embeds a standard Wii TPL (0x0020AF30, 1 image, table offset 0xc) running to EOF.'
seq:
  - id: magic
    contents: ERTM
  - id: version
    type: u4
  - id: rest
    size-eos: true
