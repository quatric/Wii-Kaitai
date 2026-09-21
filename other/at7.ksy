meta:
  id: at7
  file-extension: at7
  endian: le
  title: AT7 block-compressed stream
doc: |
  A sequence of tagged blocks, terminated by a 4-byte `AT7E` marker with
  no body. `AT7X` blocks store their payload raw; `AT7P` blocks RLE-pack
  it behind a bit-flag byte (each set bit copies one literal byte from
  the stream, each clear bit emits a byte from a small back-reference
  window -- see lib-at7.c's `DecodeAT7` for the exact RLE rule, which
  isn't captured here since it's a byte-level decode loop rather than a
  fixed field layout).
seq:
  - id: blocks
    type: block
    repeat: until
    repeat-until: _.tag == "AT7E"
types:
  block:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        valid:
          any-of: ['"AT7X"', '"AT7P"', '"AT7E"']
      - id: len_block
        type: u2
        if: tag != "AT7E"
        doc: Total block size, this 6-byte sub-header included.
      - id: body
        size: len_block - 6
        if: tag != "AT7E"
        type:
          switch-on: tag
          cases:
            '"AT7X"': raw_block
            '"AT7P"': packed_block
  raw_block:
    seq:
      - id: data
        size-eos: true
  packed_block:
    doc: |
      A bit-flag byte followed by up to 8 tokens (one bit each, MSB
      first): a set bit is a literal byte, a clear bit is a
      back-reference token; see lib-at7.c for the exact byte layout of
      a back-reference token, which this .ksy leaves opaque.
    seq:
      - id: data
        size-eos: true
