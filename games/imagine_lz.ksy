meta:
  id: imagine_lz
  title: Ubisoft Imagine compressed asset
  endian: le
doc: |
  Ubisoft "Imagine" engine compressed asset (Babysitting Party, Babyz, Beastly,
  ...; any extension: `.wiz .wsp .wsn .tan .wan .msk .cam .wik .spt .h`). Okumura
  LZSS: a 4096-byte ring filled with 0x20 and written from position 4078, groups
  of 8 tokens under a control byte (LSB first; 1 = literal byte, 0 = 2-byte match
  `{b0, b1}`: ring position `b0 | (b1 & 0xF0) << 4`, length `(b1 & 15) + 3`).
seq:
  - id: magic
    contents: [0x21, 0x43, 0x65, 0x87]
  - id: len_compressed
    type: u4
    doc: File size - 12.
  - id: len_decompressed
    type: u4
  - id: stream
    size-eos: true
