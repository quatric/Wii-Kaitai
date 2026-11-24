meta:
  id: lang_str
  title: Localised string table (.str, Humongous / Atari Wii ports)
  file-extension: str
  endian: be
doc: |
  Localised string table (Freddi Fish: Kelp Seed Mystery `lang_en.str` and other
  Humongous / Atari Wii ports). UTF-16BE strings are stored back to back after
  the table (the first offset is `12 + 8 * count`).
seq:
  - id: tag
    type: u4
    doc: Varies.
  - id: version
    type: u4
    doc: Bytes 01 00 00 00.
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: len_bytes
        type: u4
    instances:
      text:
        pos: offset
        io: _root._io
        type: str
        size: len_bytes
        encoding: UTF-16BE
