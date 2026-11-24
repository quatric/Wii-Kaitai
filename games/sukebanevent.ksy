meta:
  id: sukebanevent
  title: Sukeban Shachou Rena event list
  file-extension: dat
  endian: le
seq:
  - id: records
    type: record
    repeat: eos
types:
  record:
    seq:
      - id: name
        size: 32
        type: strz
        encoding: ASCII
      - id: flag
        type: u1
      - id: group
        type: u1
