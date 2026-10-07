meta:
  id: soma_dad
  title: Monolith Soft DAD LZSS container (Soma Bringer .dad)
  file-extension: dad
  endian: le
doc: |
  Monolith Soft's DAD LZSS stream (Soma Bringer; 20 `.dad` archives verified
  against ARM9 disassembly). The 8-byte header is the magic `DAD\x01` (nintoolbox
  also accepts `DAD\x02`) plus the little-endian uncompressed size.

  Decoding: flag bytes are consumed least-significant bit first. A set bit is
  a literal byte. A clear bit is a two-byte reference `b1 b2` with
  `dist = b1 | ((b2 & 0xf0) << 4)` and `len = (b2 & 0x0f) + 3`, copying from
  `dist` bytes *back from the current output position* (a plain sliding
  window, not a ring buffer); `dist == 0` or `dist` larger than the output so far
  is invalid. Decompresses to `OBP1` graphics, `DFN\0` fonts and `PACK`
  databases (`database.dad`).
seq:
  - id: magic
    contents: 'DAD'
  - id: version
    type: u1
    valid:
      any-of: [1, 2]
  - id: uncompressed_size
    type: u4
    doc: Must be non-zero and at most 128 MiB.
  - id: stream
    size-eos: true
    doc: Flag / literal / reference stream, decoded as described above.
