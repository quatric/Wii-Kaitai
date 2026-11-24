meta:
  id: vliblib
  title: VLIB variable library (Meet the Robinsons)
  file-extension: lib
  endian: le
doc: Record data is a tokenised form of .var text files; the trailing index is not decoded.
seq:
  - id: magic
    contents: VLIB
  - id: x100
    type: u4
  - id: count
    type: u4
  - id: payload_size
    type: u4
  - id: index_entry_count
    type: u4
  - id: index_size
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: length
        type: u2
      - id: name
        type: strz
        encoding: ASCII
      - id: data
        size: length - name.length - 1
