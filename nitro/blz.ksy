meta:
  id: blz
  endian: le
  title: Nintendo "backward LZSS" (BLZ) compression wrapper
doc: |
  The DS/3DS ARM-binary compression used by ndstool to shrink arm9.bin,
  arm7.bin and overlays -- an LZSS variant whose control/back-reference
  stream is written from the *end* of the file backward, decoded forward
  only after the compressed span has been reversed in memory.

  A BLZ file carries no magic of its own; it is a plain LZSS payload with
  a small trailer at the very end that describes how to unpack it. The
  trailer's last four bytes (`inc_len`) are the giveaway: a zero there
  means compression made the file no smaller, so the encoder gave up and
  the "compressed" file is simply the original bytes plus this trailer,
  stored verbatim.

  Layout, all fields read from the tail of the file: last 4 bytes
  `inc_len` (0 => not compressed, whole file is the plain payload plus
  this trailer); if nonzero, byte at `-5` is the trailer length
  (`hdr_len`, 8-11), and the 3 bytes before that plus a 0-padded top byte
  form `enc_len` (the compressed span's length, trailer included, masked
  to 24 bits). `dec_len = file_size - enc_len` is a leading span stored
  as plain, uncompressed bytes; the remaining `enc_len - hdr_len` bytes
  right before the trailer are the actual reversed LZSS stream.
seq:
  - id: body
    size-eos: true
    doc: |
      The whole file as opaque bytes. BLZ's fields are only meaningful
      read backward from the end (see `trailer` and the doc above); there
      is no forward-readable header to declare here.
instances:
  inc_len:
    pos: _io.size - 4
    type: u4
    doc: |
      Extra bytes the decompressed output has beyond `enc_len`. Zero
      means the payload was left uncompressed (raw passthrough).
  is_compressed:
    value: inc_len != 0
  hdr_len:
    pos: _io.size - 5
    type: u1
    if: is_compressed
    doc: Length of this trailer itself (8-11 bytes).
  enc_len_and_pad:
    pos: _io.size - 8
    type: u4
    if: is_compressed
  enc_len:
    value: 'is_compressed ? (enc_len_and_pad & 0xffffff) : 0'
    doc: Length of the compressed span, trailer included.
  dec_len:
    value: 'is_compressed ? _io.size - enc_len : _io.size'
    doc: Length of the leading plain (uncompressed) span.
  plain_head:
    pos: 0
    size: dec_len
    doc: Leading bytes stored verbatim, ahead of the compressed span.
  compressed_tail:
    pos: dec_len
    size: 'is_compressed ? enc_len - hdr_len : 0'
    if: is_compressed
    doc: |
      The reversed LZSS stream. Must be reversed byte-for-byte before
      the ordinary forward LZSS flag/back-reference decode applies.
