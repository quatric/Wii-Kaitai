meta:
  id: jdlz
  title: EA Black Box JDLZ compressed file (.lzc)
  file-extension: lzc
  endian: le
doc: |
  EA Black Box `JDLZ` compressed file (Need for Speed - Nitro `*.lzc`, NFS
  Underground 2 / Most Wanted / Carbon chunks). Two flag bytes f1/f2 (consumed
  LSB first, refilled when they run out) and the data from +18. f1 bit set =
  match: 2 bytes b0 b1; if the f2 bit is set, length = `((b0 & 0xF0) << 4 | b1)
  + 3` and distance = `(b0 & 0xF) + 1`, otherwise distance = `((b0 & 0xE0) << 3
  | b1) + 17` and length = `(b0 & 0x1F) + 3` (the f2 bit is only consumed by
  matches); f1 bit clear = literal byte. As in the public open-nfs-bin-viewer.
seq:
  - id: magic
    contents: JDLZ
  - id: version
    contents: [0x02, 0x10, 0x00, 0x00]
  - id: len_inflated
    type: u4
  - id: len_compressed
    type: u4
    doc: The whole file.
  - id: flag_bytes
    size: 2
  - id: stream
    size-eos: true
