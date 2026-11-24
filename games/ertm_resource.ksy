meta:
  id: ertm_resource
  title: Telltale ERTM metastream resource (.aud / .d3dtx)
  endian: le
doc: |
  "ERTM" {u32 version (1 for .aud), u32 name crc, u32 crc, ...}. The payload
  embeds an Ogg Vorbis stream (.aud: first "OggS" within 0x100 bytes to EOF) or
  a standard Wii TPL (.d3dtx: magic 0x0020AF30, 1 image, table offset 0xc, to EOF).
seq:
  - id: magic
    contents: ERTM
  - id: version
    type: u4
  - id: name_crc
    type: u4
  - id: crc
    type: u4
  - id: body
    size-eos: true
