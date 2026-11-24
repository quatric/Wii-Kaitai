meta:
  id: ffx_sysm
  title: Earth Seeker SYSM message file (.ffx)
  file-extension: ffx
  endian: be
doc: |
  Earth Seeker (Wii) `FFX/*.ffx` message file. From 0x20 an ascending table of
  `2 * pairs` u32 offsets into the text pool: pair i is the label
  `[o[2i], o[2i+1])` and the message `[o[2i+1], o[2i+2])` (the last one runs to
  the end of the file), both NUL-terminated Shift-JIS. Messages hold `^t[..]` /
  `^c[..]` control tags.
seq:
  - id: magic
    contents: SYSM
  - id: one0
    type: u1
  - id: one1
    type: u1
  - id: zero
    type: u2
  - id: header_size_a
    type: u4
    doc: 0x20.
  - id: text_pool_offset
    type: u4
  - id: header_size_b
    type: u4
    doc: 0x20.
  - id: num_pairs
    type: u4
  - id: reserved
    size: 8
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: 2 * num_pairs
    doc: Relative to the text pool.
