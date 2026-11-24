meta:
  id: vetdata_edf
  title: Real Stories Veterinarian .edf animation event list
  file-extension: edf
  endian: le
seq:
  - id: zero
    type: u4
  - id: count
    type: u4
  - id: names
    type: pstr
    repeat: expr
    repeat-expr: count
  - id: records
    type: record
    repeat: eos
types:
  pstr:
    seq:
      - id: len
        type: u1
      - id: text
        size: len
        type: str
        encoding: ASCII
  record:
    seq:
      - id: name
        type: pstr
      - id: value
        type: u4
