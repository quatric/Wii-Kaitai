meta:
  id: rcb
  title: Bass Fishing Wii resource bundle (.rcb)
  file-extension: rcb
  endian: be
doc: |
  `.rcb` resource bundle (Bass Fishing Wii / Big Catch, e.g.
  `system/sys_lang_en.rcb`). A 0x40-byte header `{0, 0x40, 1, ..., name at
  0x20}`, then members each behind a 0x40-byte header, payload right after it
  (BRFNT / BRRES ...).
seq:
  - id: zero
    type: u4
  - id: header_size
    type: u4
    doc: 0x40.
  - id: one
    type: u4
  - id: reserved
    size: 0x14
  - id: bundle_name
    size: 0x20
    type: strz
    encoding: ASCII
  - id: members
    type: member
    repeat: until
    repeat-until: _.flag == 1 or _io.eof
types:
  member:
    seq:
      - id: span
        type: u4
        doc: Header + payload, rounded up to 0x20.
      - id: header_size
        type: u4
        doc: 0x40.
      - id: len_payload
        type: u4
      - id: flag
        type: u4
        doc: 1 = last member.
      - id: reserved
        size: 0x10
      - id: path
        size: 0x20
        type: strz
        encoding: ASCII
      - id: payload
        size: len_payload
      - id: padding
        size: span - 0x40 - len_payload
