meta:
  id: xmsg
  endian: be
  title: Wii Party Message and Text Archive (XMSG)
doc: |
  Wii Party Message and Text Archive (mess.bin), per lib-xmsg.h/.c.
  Style entries (16 bytes each: color, outline, width, height,
  spacing, state markers) live at the lowest style_offset referenced
  by any message and are not modeled here beyond that pointer.
seq:
  - id: magic
    contents: [0x58, 0x4d, 0x53, 0x47, 0x20, 0x10, 0x05, 0x03]
  - id: num_messages
    type: u4
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_messages
types:
  entry_t:
    seq:
      - id: name_offset
        type: u4
      - id: text_offset
        type: u4
        doc: UTF-16BE, NUL-terminated.
      - id: type_offset
        type: u4
        doc: UTF-8, NUL-terminated.
      - id: style_offset
        type: u4
    instances:
      name:
        pos: name_offset
        type: str
        terminator: 0
        encoding: ASCII
        io: _root._io
        if: name_offset < _root._io.size
      type_name:
        pos: type_offset
        type: str
        terminator: 0
        encoding: ASCII
        io: _root._io
        if: type_offset < _root._io.size
