meta:
  id: sonic_xtb
  title: Sonic Team text table (.xtb, Sonic Colors)
  file-extension: xtb
  endian: le
seq:
  - id: ff_pad
    size: 8
  - id: version
    type: u2
    doc: 2.
  - id: style_count
    type: u2
  - id: unk
    size: 6
  - id: styles
    type: style
    repeat: expr
    repeat-expr: style_count
  - id: group_count
    type: u4
  - id: zero
    type: u4
  - id: groups
    type: group
    repeat: expr
    repeat-expr: group_count
types:
  pstr:
    seq:
      - id: len
        type: u1
      - id: text
        size: len
        type: str
        encoding: ASCII
  style:
    seq:
      - id: name
        type: pstr
      - id: params
        size: 10
        doc: '{1, font size, 0, 0, 0, r, g, b, 0, 0}.'
  group:
    seq:
      - id: name
        type: pstr
      - id: message_count
        type: u1
      - id: messages
        type: message
        repeat: expr
        repeat-expr: message_count
  message:
    seq:
      - id: id
        type: pstr
      - id: style
        type: pstr
      - id: text_bytes
        type: u4
      - id: text_chars
        type: u4
      - id: text
        size: text_bytes
        type: str
        encoding: UTF-16LE
