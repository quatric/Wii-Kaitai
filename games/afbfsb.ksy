meta:
  id: afbfsb
  title: HVSIAFB audio file bank (.AFB)
  file-extension: afb
  endian: be
doc: |
  Billy & Mandy (Wii). Header {"HVSIAFB\0" (random bytes in some files), u32 file
  size at 0x0c, u32 0x14, descriptor words, zero padding to 0x800}, then one
  complete FMOD FSB3 bank to the end of the file.
seq:
  - id: magic
    size: 8
  - id: file_size
    type: u4
  - id: x14
    type: u4
  - id: descriptor
    size: 0x800 - 0x10 - 4
    doc: 0x14 at 0x10 then words and padding.
  - id: fsb
    size-eos: true
