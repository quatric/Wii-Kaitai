meta:
  id: pixtpl
  title: Earth Seeker .pix texture wrapper
  file-extension: pix
  endian: le
doc: Chunks "FPIX" / "DPIX" / "XPIX" (little-endian sizes) in front of a complete TPL (0x0020AF30) that runs to EOF.
seq:
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: 3
  - id: tpl
    size-eos: true
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size - 8
