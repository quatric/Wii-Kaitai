meta:
  id: uranai_ephemeris
  title: Today & Tomorrow Channel - logic/wii_ephemeris_decimal_<band>.bin
  application: Today & Tomorrow Channel
  file-extension: bin
  endian: be
  bit-endian: be
doc: |
  The planetary-position table behind every fortune. One 16-byte record per calendar day,
  1881-01-01 to 2036-12-31 inclusive: 56,978 records, 911,648 bytes. The console copies the
  whole file into a static buffer at 0x80339A60 (0x80026A7C, 0xDE920 bytes) and finds a
  record by walking from `(year - 1881) * 365` records (0x80026B7C, which also asserts
  year 0x759..0x7F4, month 1..12, day 1..31).

  Each record is a date and nine ecliptic longitudes in WHOLE degrees, nine bits each,
  packed three to a 32-bit word (27 bits used, 5 padding). The game extracts field n with
  a generic n-bit reader (0x8005BB18, `field = word[n / 3] >> (32 - 9 - 9 * (n % 3))`).

  The bands are the same ephemeris sampled at local midnight of a UTC offset:
  A +1, B +2, I +9, K +10, M +12, Z 0 (the console country picks one by longitude,
  0x800EC088). The European WAD ships A, B, K, M and Z; the Korean WAD ships I; the
  Japanese build embeds I in its main program at 0x80260E70.

  Field order (checked against a low-precision orbital model, mean error under 1 degree,
  and against the Moon's 12-15 degree daily motion): Sun, Venus, Moon at midnight,
  Saturn, Mercury, Jupiter, Mars, Moon about twelve hours later, and an unused zero.
  The fortune maths reads a natal record for the person and a day record for the day.
seq:
  - id: days
    type: day
    repeat: eos
types:
  day:
    seq:
      - id: year
        type: u2
      - id: month
        type: u1
      - id: day
        type: u1
      - id: sun
        type: b9
      - id: venus
        type: b9
      - id: moon_midnight
        type: b9
      - id: pad0
        type: b5
      - id: saturn
        type: b9
      - id: mercury
        type: b9
      - id: jupiter
        type: b9
      - id: pad1
        type: b5
      - id: mars
        type: b9
      - id: moon_noon
        type: b9
        doc: the Moon about 12 hours after `moon_midnight`; the day-side input of the fortune index
      - id: unused
        type: b9
        doc: always 0
      - id: pad2
        type: b5
