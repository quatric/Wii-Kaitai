meta:
  id: sega_melt
  title: SEGA / War Drum "Melt" compressed stream
doc: |
  An LZ with every byte and every flag bit inverted. Flags are read LSB first from
  an inverted byte; flag 1 = literal; else flag 1 = long match {b0, b1, (b2)}
  (len = b0 & 7, 0 = b2 + 1 else + 2; offset = b1 * 0x20 + (b0 >> 3) - 0x2000,
  both bytes 0 ends the stream), flag 0 = short match (2 flag bits = length - 2,
  one byte, offset - 0x100). 8 KiB window, initially zero.
seq:
  - id: stream
    size-eos: true
