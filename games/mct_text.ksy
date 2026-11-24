meta:
  id: mct_text
  title: Storybook Workshop menu text (.mct)
  file-extension: mct
  endian: be
doc: |
  Storybook Workshop (USA) `MenuTextData_<lang>.mct`. `count` u32 offsets (in
  UTF-16 units) relative to the pool that follows the offset table
  (`0x24 + 4 * count`), holding NUL-terminated UTF-16BE strings.
seq:
  - id: count
    type: u2
  - id: count_again
    type: u2
  - id: header_rest
    size: 0x20
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
    doc: In UTF-16 units.
