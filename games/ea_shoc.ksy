meta:
  id: ea_shoc
  title: EA Sports SHOC chunk stream (Tiger Woods PGA Tour .hog / .gcb)
  file-extension: hog
  endian: be
doc: |
  Electronic Arts big-endian chunk stream used by the Tiger Woods PGA Tour
  `.hog` and `.gcb` files: `{4-char tag, u4 size including the 8-byte header}`.
  Top-level tags are `CTRL`, `FILL` (padding) and `SHOC`. A `SHOC` body is two
  zero words, a 4-char tag and the tag's payload. `SHDR` (`u4 version`,
  `char type[4]`, `u4 id`, `u4 length`, ...) opens a resource; the `Zdat`
  (`u4 len`, zlib bytes) and `SDAT` (`u4 len`, raw bytes) chunks that follow
  up to the next `SHDR` carry its data. All `Zdat` parts of one resource form
  a single zlib stream. nintoolbox writes members as `<type>_<id>.bin`.

  Not related to the little-endian `HOG` archive of Ultimate Band
  (`hog.ksy`).
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
        doc: Includes the 8-byte header.
      - id: body
        size: size - 8
        type:
          switch-on: tag
          cases:
            '"SHOC"': shoc_body
  shoc_body:
    seq:
      - id: zero0
        type: u4
      - id: zero1
        type: u4
      - id: sub_tag
        type: str
        size: 4
        encoding: ASCII
      - id: payload
        size-eos: true
        type:
          switch-on: sub_tag
          cases:
            '"SHDR"': shdr
            '"Zdat"': data_part
            '"SDAT"': data_part
  shdr:
    seq:
      - id: version
        type: u4
      - id: type
        type: str
        size: 4
        encoding: ASCII
      - id: id
        type: u4
      - id: length
        type: u4
      - id: rest
        size-eos: true
  data_part:
    seq:
      - id: length
        type: u4
      - id: bytes
        size-eos: true
        doc: zlib bytes for `Zdat`, raw bytes for `SDAT`.
