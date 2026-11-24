meta:
  id: lipb_sync
  title: Batman Brave and the Bold lip sync track (.lipb)
  file-extension: lipb
  endian: be
doc: |
  Batman: The Brave and the Bold (Wii) lip sync track. The file ends with the
  last key.
seq:
  - id: zero0
    type: u4
  - id: sound_name
    size: 60
    type: strz
    encoding: ASCII
    doc: E.g. `f_1_012_batman.ogg`.
  - id: zero1
    type: u4
  - id: num_keys
    type: u4
  - id: keys_offset
    type: u4
    doc: 0x4c.
  - id: keys
    type: key
    repeat: expr
    repeat-expr: num_keys
types:
  key:
    seq:
      - id: time_seconds
        type: f4
      - id: viseme_index
        type: u4
        doc: 0-7.
