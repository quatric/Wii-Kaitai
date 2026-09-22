meta:
  id: at7
  file-extension: at7
  endian: le
  title: AT7 block-compressed stream
doc: |
  A sequence of tagged blocks, conventionally terminated by a 4-byte
  `AT7E` marker with no body. `AT7X` blocks store their payload raw;
  `AT7P` blocks use LZ-style back-references, not run-length encoding.
  The 16-bit little-endian block length includes the six-byte tag/length
  prefix. The decoder rejects lengths below six or beyond EOF.

  In each packed block, a flag byte controls up to eight tokens, consumed
  from bit 7 down to bit 0. A set bit copies one literal byte. A clear bit
  consumes a little-endian 16-bit token: zero emits nothing; otherwise
  its low nibble plus three is the match length (3..18), and its upper
  12 bits are the backtrack distance. Distance zero or beyond the bytes
  already produced is invalid. Matches copy from the global output buffer,
  so they can refer across block boundaries and can overlap themselves.
  A final group may contain fewer than eight tokens if the block ends.
  Token expansion is procedural and is not performed by this schema.

  The decoder stops at AT7E and ignores trailing bytes. It also succeeds
  if EOF is reached without AT7E (even with fewer than four trailing
  bytes), whereas this Kaitai parser expects the conventional terminator.
  The writer always emits
  AT7P blocks (up to 0x7ff0 input bytes each) followed by AT7E, even
  when an AT7X block might be smaller; it emits just AT7E for empty input.
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
      Repeated flag groups and variable-width tokens; the exact
      literal/back-reference rules are described in the format doc.
      Kept raw because token width depends on each flag bit.
    seq:
      - id: data
        size-eos: true
