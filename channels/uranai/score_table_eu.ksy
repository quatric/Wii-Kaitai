meta:
  id: uranai_score_table_eu
  title: Today & Tomorrow Channel - fortune score table (EU and Korean builds)
  application: Today & Tomorrow Channel
  endian: be
doc: |
  Compiled into the main program, not a file: six tables of 360 entries of 28 bytes,
  0x2760 bytes apart, starting at 0x802C6710 (EU) / 0x802D7738 (Korea). Slice
  `6 * 0x2760` bytes from that address to parse it.

  Tables 0-4 are the fortune topics in the order love, work, study, communications,
  money. The 360 entries of a table are the zodiac circle: entry `i` is sign `i / 30`,
  degree `i % 30 + 1`. The fortune index is `(natal planet + day's Moon) mod 360`
  (0x80026E14), with 0 taken as 360 and entry `index - 1` used, and it selects both this
  entry's score and message number `topic * 360 + index - 1` of the text file.

  `score` is 10-20 and is the only thing scoring reads (capped at 20; on ~80% of dates a
  hash flag cuts 13/12/11/10 to 6/4/2/0, see 0x80027010). Stars per topic: 10-11 one,
  12-13 two, 14-15 three, 16-17 four, 18-20 five (0x80027250).

  The six `line_pointers` are NOT in the shipped file: the text loader (0x80026ACC) splits
  the fortune text in place into up to six tab-terminated UTF-16 lines and stores their
  addresses here at start-up. Its outer loop runs over topics 0-4 only.

  Table 5 (natal Sun) exists in every build and carries a pointer to a Japanese one-liner
  in its first line pointer, but nothing reads it: every caller of the score lookup
  (0x80042A3C, 0x8005ED90, 0x8005FA3C, 0x80091C48, 0x80094F78, 0x80097144, 0x800B6B44,
  and the hint and compatibility code) loops over topics 0-4 or passes a constant 0-4.
seq:
  - id: topics
    type: topic
    repeat: expr
    repeat-expr: 6
types:
  topic:
    seq:
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: 360
  entry:
    seq:
      - id: sign
        type: u1
        doc: 0-11, Aries first; always `index / 30`
      - id: degree
        type: u1
        doc: 1-30; always `index % 30 + 1`
      - id: score
        type: u1
        doc: 10 to 20; higher is luckier
      - id: zero
        type: u1
      - id: line_pointers
        type: u4
        repeat: expr
        repeat-expr: 6
        doc: filled in at run time; 0 in the shipped program (table 5 excepted, see above)
