meta:
  id: loc
  title: Ubisoft Imagine LOCV1.0 localisation table (.LOC)
  file-extension: loc
  endian: le
doc: |
  LZSS wrapped on disc. ".LOCV1.0", u32 id, 4-byte language tag ("!DE\0"), then
  LE u32 string offsets from 0x10 up to the first string (the table end is the
  smallest 4-aligned offset that equals 0x10 + 4 * index), followed by
  NUL-terminated Latin-1 texts.
seq:
  - id: magic
    contents: ".LOCV1.0"
  - id: id
    type: u4
  - id: language
    size: 4
  - id: rest
    size-eos: true
