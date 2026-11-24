meta:
  id: ertmaud
  title: Telltale .aud sound effect (Ogg Vorbis in ERTM)
  file-extension: aud
  endian: le
doc: '"ERTM" {u32 version 1, u32 name crc, u32 crc, ...} with an Ogg Vorbis stream (first "OggS" within the first 0x100 bytes, to EOF).'
seq:
  - id: magic
    contents: ERTM
  - id: version
    type: u4
  - id: name_crc
    type: u4
  - id: crc
    type: u4
  - id: rest
    size-eos: true
