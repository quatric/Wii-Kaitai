meta:
  id: pak3
  title: PAK\3 archive (International Athletics)
  file-extension: pak
  endian: le
doc: |
  `PAK\3` archive (International Athletics `GameData.pak`, 138 MB). Payloads
  follow the table. Members with `len_stored == len_unpacked` are raw, the
  others use a byte-oriented LZSS: after a 4-byte member header, u16 LE control
  words (LSB first); a clear bit is a literal byte, a set bit a 2-byte match
  `{b0, b1}`: length `(b0 & 15) + 1`, distance `b1 | (b0 >> 4) << 8`.
seq:
  - id: magic
    contents: ['PAK', 3]
  - id: num_entries
    type: u4
  - id: one
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        size: 128
        type: strz
        encoding: ASCII
        doc: Backslash paths.
      - id: len_stored
        type: u4
      - id: len_unpacked
        type: u4
      - id: offset
        type: u4
