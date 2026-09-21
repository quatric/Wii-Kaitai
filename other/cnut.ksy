meta:
  id: cnut
  file-extension:
    - cnut
    - nut
  endian: be
  title: Compiled Squirrel script archive (Wii Party / Nd Cube)
doc: |
  Compiled Squirrel scripting-language bytecode container (SQIR), used by
  Wii Party and other Nd Cube games. The file opens with a 16-bit stream
  tag followed by a 4-byte magic and a character-size field; the bulk of
  the file is a recursively-encoded `SQFunctionProto` object tree, whose
  shape depends on run-time type tags at each object and is not modelled
  here as a static struct.
seq:
  - id: stream_tag
    type: u2
    valid: 0xfafa
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: Squirrel bytecode magic, observed as "SQIR".
  - id: char_size
    type: u4
    doc: Size in bytes of a Squirrel character in this stream (1 or 2).
