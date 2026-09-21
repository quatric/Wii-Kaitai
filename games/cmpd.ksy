meta:
  id: cmpd
  endian: be
  title: Retro Studios CMPD compression wrapper (used inside RPAK)
doc: |
  Retro Studios' CMPD wrapper for an RPAK entry payload. It is a directory of
  8-byte block headers followed by the corresponding block byte streams in
  header order. The directory's first byte is commonly 0xc0 for a zlib block
  and 0x00 for a stored block in nintoolbox output, but the decoder does not
  consult it: compression is determined from the stored and output sizes and
  the bytes themselves.

  Each header packs a 24-bit stored length and a 32-bit decompressed length.
  If the two lengths are equal, the block is copied verbatim. Otherwise the
  decoder first attempts a segmented representation: each segment has a
  big-endian 16-bit tag/length, where bit 15 selects a raw segment whose size
  is `0x10000 - word`; a clear bit selects a compressed segment whose size is
  `word`. A compressed segment beginning `78 01`, `78 9c`, or `78 da` is zlib;
  every other compressed segment is LZO1X. If the segment walk fails to
  consume precisely the stored bytes and produce precisely the declared
  output, the decoder retries the entire block as one zlib stream.

  nintoolbox rejects more than 0x100000 blocks, a truncated header table or
  block range, arithmetic overflow, and a combined decoded size above 256 MiB.
  Its writer currently emits exactly one block and chooses zlib only when it
  makes the data smaller; otherwise it emits a stored block.
seq:
  - id: magic
    contents: "CMPD"
    doc: ASCII signature `CMPD` (0x434d5044).
  - id: num_blocks
    type: u4
    doc: Number of 8-byte headers in the directory. The corresponding stored
      blocks begin immediately after the complete header table.
  - id: blocks
    type: block_header_t
    repeat: expr
    repeat-expr: num_blocks
    doc: Directory of block headers; all stored block byte streams follow it.
  - id: stored_payloads
    size-eos: true
    doc: >-
      Concatenated stored block streams in directory order.  Each block's
      exact span is given by blocks[i].stored_size; decoding walks this area
      cumulatively because CMPD stores no per-block offsets.
instances:
  payload_offset:
    value: 8 + num_blocks * 8
    doc: Absolute offset of the first stored block, immediately after the directory.
types:
  block_header_t:
    seq:
      - id: method
        type: u1
        doc: |
          Producer hint byte. nintoolbox writes 0xc0 for a zlib block and 0x00
          for a stored block, but its decoder deliberately does not branch on
          this field.
      - id: stored_size_hi
        type: u1
      - id: stored_size_mid
        type: u1
      - id: stored_size_lo
        type: u1
      - id: uncompressed_size
        type: u4
        doc: Exact number of output bytes required from this block.
    instances:
      stored_size:
        value: (stored_size_hi << 16) | (stored_size_mid << 8) | stored_size_lo
        doc: 24-bit big-endian number of bytes stored for this block in the
          payload region after the directory.
