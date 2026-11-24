meta:
  id: u8ctext
  title: Bass Fishing Wii .u8c string container
  file-extension: u8c
  endian: be
seq:
  - id: magic
    contents: U8C0
  - id: header_size
    type: u4
    doc: 0x10.
  - id: file_size
    type: u4
  - id: zero
    type: u4
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
        doc: Includes the 16-byte header.
      - id: value
        type: u4
        doc: String count for STRS.
      - id: zero
        type: u4
      - id: body
        size: size - 16
    doc: STRS holds `value` NUL-terminated UTF-8 strings back to back.
