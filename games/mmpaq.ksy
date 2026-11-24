meta:
  id: mmpaq
  title: Mercury Meltdown Revolution archive (.paq)
  file-extension: paq
  endian: be
doc: |
  Mercury Meltdown Revolution `*.paq` (Ignition Banbury). There are no names;
  members are U.8 archives, text or raw data.
seq:
  - id: version
    type: u4
    doc: 2001.
  - id: count
    type: u4
  - id: data_start
    type: u4
    doc: '`0x10 + count * 16`.'
  - id: zero
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: name_hash
        type: u4
      - id: len_data
        type: u4
      - id: offset
        type: u4
      - id: zero
        type: u4
