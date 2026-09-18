meta:
  id: uranai_colour_table
  title: Today & Tomorrow Channel - lucky-colour table (color/*.txt, embedded form)
  application: Today & Tomorrow Channel
  endian: be
  bit-endian: be
doc: |
  The runtime form of the lucky-colour data: 16,071 rows (2007-01-01 to 2050-12-31), 12
  bytes each - the date, then one 5-bit colour index (0-22) for each of the twelve zodiac
  signs, Aries first. The colour shown is the entry for the person's Sun sign,
  `(sun_degree - 1) / 30` (0x80027578), in the row of the day (0x80027374; for dates outside
  2007-2036 the row is `(day + (year << month)) % 16071`, a hash, not a lookup).

  The European build ships this as text (`color/wii_color_japanese_<band>.txt`, Shift-JIS,
  one `2007年 1月 1日,07,02,...` line per day) and parses it at start-up into a table at
  0x802D5350 (0x8002768C). The Korean and Japanese builds embed the binary rows directly:
  Korea at 0x80270C10, Japan at 0x80376D08, byte-identical, both band I (UTC+9).
seq:
  - id: rows
    type: row
    repeat: expr
    repeat-expr: 16071
types:
  row:
    seq:
      - id: year
        type: u2
      - id: month
        type: u1
      - id: day
        type: u1
      - id: first_half
        type: half
        doc: signs 1-6 (Aries to Virgo)
      - id: second_half
        type: half
        doc: signs 7-12 (Libra to Pisces)
  half:
    seq:
      - id: colour
        type: b5
        repeat: expr
        repeat-expr: 6
      - id: pad
        type: b2
