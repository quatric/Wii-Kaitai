meta:
  id: tvser
  title: Thrillville Off the Rails serialised objects (.prk / .tbp / .atr)
  endian: le
doc: |
  Magic ("PARK" / "TRAK" / "ATTR") + a packed token stream written by the
  game's stream class. Token by first byte: 00-7f signed 7-bit int; 80-bf 4-byte
  float (30 bits: low 6 bits of the first byte, then 8/8/8 bits LE; sign at bit
  29, exponent - 96 in 6 bits at 23.., 23-bit mantissa); c0-cf signed 12-bit
  (low nibble + 1 byte << 4); d0-df signed 20-bit; e0-ef signed 28-bit; f0 / f1
  32-bit LE; f2 / f3 false / true; f4-f7 signed 10-bit milli fixed point
  (/1000); f8 raw LE float32; fa u8; fb u16 LE; fc string (chars until one with
  bit 7 set, which carries the last char); ff end marker. The first token is a
  version (109 for ATTR / TRAK, 113 for PARK).
seq:
  - id: magic
    size: 4
  - id: tokens
    type: token
    repeat: eos
types:
  token:
    seq:
      - id: first
        type: u1
      - id: rest
        size: len_rest
      - id: string_chars
        type: u1
        repeat: until
        repeat-until: (_ & 0x80) != 0
        if: first == 0xfc
        doc: Characters up to and including the one with bit 7 set; that one carries the last character in its low 7 bits.
    instances:
      is_end:
        value: first == 0xff
      len_rest:
        value: >-
          first < 0x80 ? 0 :
          first < 0xc0 ? 3 :
          first < 0xd0 ? 1 :
          first < 0xe0 ? 2 :
          first < 0xf0 ? 3 :
          first < 0xf2 ? 4 :
          first < 0xf4 ? 0 :
          first < 0xf8 ? 1 :
          first == 0xf8 ? 4 :
          first == 0xfa ? 1 :
          first == 0xfb ? 2 : 0
