meta:
  id: lngtab
  title: Arctic Tale Language_<LANG>.lng
  file-extension: lng
  endian: le
doc: Offsets are relative to the end of the offset table; key names come from the sibling Language.ids.
seq:
  - id: magic
    contents: LANG
  - id: version
    type: u4
    doc: 3.
  - id: count
    type: u4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: The first is 0 (empty string).
  - id: strings
    size-eos: true
    doc: NUL-terminated UTF-8.
