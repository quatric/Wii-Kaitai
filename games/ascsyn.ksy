meta:
  id: ascsyn
  title: Scrabble Interactive rack-leave table (AscSortedSynN.bin)
  file-extension: bin
  endian: be
doc: |
  No header. count * {char key[N], u16 value}, N = 1..6 from the file name,
  letters 'a'.. ('`' is the blank), sorted ascending; values cluster around
  0x8000. Parameterised by `key_length`.
params:
  - id: key_length
    type: u4
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: key
        size: _root.key_length
        type: str
        encoding: ASCII
      - id: value
        type: u2
