meta:
  id: ten_minute_lzss
  title: 10 Minute Solution LZSS container (.tplc / .gfx / .xpf)
  endian: be
doc: |
  LZSS container of 10 Minute Solution (`.tplc` textures, `.gfx` Scaleform GFx
  movies, `.xpf` UTF-16 script data). The stream is a series of groups: a flag
  byte, read least-significant bit first, then up to eight items. A set bit
  is a literal byte; a clear bit is a little-endian `u2` match `t` with
  `len = (t & 15) + 3` and `pos = t >> 4` into a zero-filled 4096-byte ring
  buffer written at `decoded offset & 4095`.

  The first four decoded bytes are the big-endian decoded size (including
  those four bytes). A decoded TPL becomes a PNG in nintoolbox; anything else
  is saved as `<name>.dec`.
seq:
  - id: groups
    type: group
    repeat: eos
types:
  group:
    seq:
      - id: flags
        type: u1
      - id: items
        type: item(flags, _index)
        repeat: expr
        repeat-expr: 8
  item:
    params:
      - id: flags
        type: u1
      - id: index
        type: s4
    seq:
      - id: literal
        type: u1
        if: is_literal and not _io.eof
      - id: match_word
        type: u2le
        if: not is_literal and not _io.eof
    instances:
      is_literal:
        value: ((flags >> index) & 1) == 1
      match_length:
        value: (match_word & 15) + 3
        if: not is_literal and not _io.eof
      match_position:
        value: match_word >> 4
        if: not is_literal and not _io.eof
