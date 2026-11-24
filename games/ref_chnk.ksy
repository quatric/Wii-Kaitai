meta:
  id: ref_chnk
  title: Reflections CHNK container (.d4c)
  file-extension: d4c
  endian: le
doc: |
  Reflections `CHNK` container (Driver: Parallel Lines `*.d4c` level files and the
  chunks nested in them). Offsets are relative to the start of the container.
seq:
  - id: magic
    contents: CHNK
  - id: len_total
    type: u4
  - id: count
    type: u4
  - id: three
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: offset
        type: u4
      - id: meta
        type: u4
      - id: len_data
        type: u4
