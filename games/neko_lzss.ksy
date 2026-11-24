meta:
  id: neko_lzss
  title: Neko Entertainment LZSS data file (.pc, .GCN)
  endian: be
doc: |
  Neko Entertainment `Cocoto Kart Racer 2` / `Cocoto Magic Circus` (Wii) data
  files: a classic LZSS stream (flag bytes read least significant bit first, bit
  set = literal byte; a clear bit = 2-byte token).
seq:
  - id: len_packed
    type: u4
    doc: File size - 8.
  - id: len_unpacked
    type: u4
  - id: lzss_stream
    size-eos: true
