meta:
  id: lso_str
  title: Zorro string table (.lso)
  file-extension: lso
  endian: le
doc: |
  The Destiny of Zorro (Wii) `GameData/data/Language/*.lso`: a sequence of
  `{u32 length, bytes}` strings with no terminator.
seq:
  - id: strings
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: len_text
        type: u4
      - id: text
        size: len_text
