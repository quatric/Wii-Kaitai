meta:
  id: s3t
  title: Planet 51 texture (.s3t)
  file-extension: s3t
  endian: be
doc: |
  Planet 51 `*.s3t` texture. A GX-tiled top-level image (no mips) follows the header.
seq:
  - id: gx_format
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: zeros
    size: 12
  - id: flags
    type: u4
    doc: 0x201.
  - id: zero
    type: u4
  - id: pixels
    size-eos: true
