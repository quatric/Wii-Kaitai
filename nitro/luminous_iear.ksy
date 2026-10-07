meta:
  id: luminous_iear
  title: Luminous Arc IEAR resource archive (MAIN/JTBL)
  endian: le
doc: |
  Luminous Arc (Nintendo DS) resource archive: a `MAIN` header, a padded
  `JTBL` directory, typed chunks and an `ENDT` footer. Recognised by the
  signature rather than a filename extension. All 331 archives / 7,511 members
  of the Luminous Arc (USA) sample match an independent directory reader byte
  for byte.

  nintoolbox validates the whole directory before exposing anything: the
  `JTBL` word count must equal `(n * 2 + 3) & ~3`; chunks must be in order,
  non-overlapping, at least 16 bytes long with `payload_size == length - 16`,
  and the last must end exactly where the 16-byte `ENDT` footer begins. Each
  chunk starts with a four-character tag (`nclr`, `ncbr`, ... in lowercase
  becomes the extension; unsafe tags fall back to `.bin`) and a 16-byte wrapper
  that nintoolbox strips.
seq:
  - id: magic
    contents: 'MAIN'
  - id: count
    type: u4
    doc: At most 100000.
  - id: main_rest
    size: 8
  - id: jtbl_magic
    contents: 'JTBL'
  - id: jtbl_words
    type: u4
    doc: Equals `(count * 2 + 3) & ~3`.
  - id: jtbl_rest
    size: 8
  - id: directory
    type: dir_entry
    repeat: expr
    repeat-expr: count
  - id: directory_padding
    size: (jtbl_words - count * 2) * 4
    doc: Pads the directory to `jtbl_words * 4` bytes.
instances:
  footer:
    pos: _io.size - 16
    size: 16
    doc: '`ENDT` followed by 12 bytes.'
types:
  dir_entry:
    seq:
      - id: offset
        type: u4
        doc: Absolute offset of the chunk.
      - id: length
        type: u4
        doc: Chunk length including its 16-byte wrapper.
    instances:
      chunk:
        pos: offset
        size: length
        type: chunk
        io: _root._io
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: Resource tag (`NCLR`, `NCBR`, ...).
      - id: payload_size
        type: u4
        doc: Equals chunk length minus 16.
      - id: wrapper_rest
        size: 8
      - id: payload
        size: payload_size
