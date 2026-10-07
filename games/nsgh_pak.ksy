meta:
  id: nsgh_pak
  title: Neversoft Guitar Hero (Wii) .pak.ngc package
  file-extension: pak.ngc
  endian: be
doc: |
  Neversoft's `.pak.ngc` package from the Wii Guitar Hero games. Layout
  worked out from the 2654 `.pak.ngc` files on the Guitar Hero: Smash Hits
  (USA) disc; all but two satisfy it. A list of 0x20-byte entry headers, then
  payloads addressed from the file start. The list ends with a header whose
  `type`, `offset` and `size` are all zero.

  Types and names are CRC hashes (type = CRC of the file extension such as
  `.qb`, `.tex`). When `flags & 0x20` a 160-byte NUL-padded path follows the
  header (`0x04` is also seen). Entries without a path are written as
  `NNNN_<namecrc>.<typecrc>`.
seq:
  - id: entries
    type: entry
    repeat: until
    repeat-until: _.is_terminator
types:
  entry:
    seq:
      - id: type_crc
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: name_crc
        type: u4
      - id: zero_10
        type: u4
      - id: short_name_crc
        type: u4
        doc: CRC of the name without path and extension.
      - id: zero_18
        type: u4
      - id: flags
        type: u4
      - id: path
        type: strz
        size: 160
        encoding: ASCII
        if: not is_terminator and (flags & 0x20) != 0
    instances:
      is_terminator:
        value: type_crc == 0 and offset == 0 and size == 0
      body:
        pos: offset
        size: size
        io: _root._io
        if: not is_terminator
