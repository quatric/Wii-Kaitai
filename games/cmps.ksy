meta:
  id: cmps
  title: Momotarou Dentetsu 16 cmps compressed blob
  endian: be
doc: |
  LZ with 32-bit big-endian flag words (MSB first): 1 = literal, 0 = match {u16
  v: length nibble = v >> 12 (0: next byte + 0x12, else nibble + 2), distance =
  (v & 0xfff) + 1}. Decoded data is a table container {u32 count, 3 zero words,
  count x u32 offsets (0x20 aligned)}.
seq:
  - id: magic
    contents: cmps
  - id: method
    type: u4
    doc: 2, 4 and 5 use the same decoder.
  - id: output_size
    type: u4
  - id: stream
    size-eos: true
