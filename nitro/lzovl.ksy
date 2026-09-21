meta:
  id: lzovl
  endian: le
  title: NDS Reverse Overlay compression (LZOvl)
doc: |
  NDS overlay compression, ported from lib-lzovl.c (split out of
  Wiimms SZS Tools' lib-nintendo.c). Like BLZ (see nitro/blz.ksy), this
  carries no magic of its own: it is raw LZSS data whose
  control/back-reference stream is written and decoded from the *end*
  of the file backward, described by a small trailer at the very end.
  The reference detector additionally requires callers to already know
  the file is an ".ovl" (there is no structural magic to gate on).

  Layout, all fields read from the tail of the file: last 4 bytes
  `inc_len` (0 => not compressed; the whole file, minus this 4-byte
  trailer, is the plain payload verbatim); if nonzero, byte at `-5` is
  the trailer length (`hdr_len`, 8-11), and the 3 bytes before that
  form `comp_len` (length of the reversed LZSS span, trailer
  excluded). `uncomp_len = file_size - hdr_len - comp_len` is a
  leading span stored as plain bytes; decompression appends
  `inc_len` extra bytes beyond `file_size` to reach the final output
  size `file_size + inc_len`.
seq:
  - id: body
    size-eos: true
    doc: |
      The whole file as opaque bytes; LZOvl's fields are only
      meaningful read backward from the end (see instances below).
instances:
  inc_len:
    pos: _io.size - 4
    type: u4
    doc: Extra decompressed bytes beyond the input size; 0 = stored uncompressed.
  is_compressed:
    value: inc_len != 0
  hdr_len:
    pos: _io.size - 5
    type: u1
    if: is_compressed
    doc: Length of this trailer itself (8-11 bytes).
  comp_len_bytes:
    pos: _io.size - 8
    type: u1
    repeat: expr
    repeat-expr: 3
    if: is_compressed
  comp_len:
    value: 'is_compressed ? (comp_len_bytes[0].as<u4> | (comp_len_bytes[1].as<u4> << 8) | (comp_len_bytes[2].as<u4> << 16)) : 0'
    doc: Length of the reversed LZSS span, trailer excluded.
  uncomp_len:
    value: 'is_compressed ? _io.size - hdr_len - comp_len : _io.size - 4'
    doc: Length of the leading plain (uncompressed) span.
  plain_head:
    pos: 0
    size: uncomp_len
  compressed_tail:
    pos: uncomp_len
    size: comp_len
    if: is_compressed
    doc: Reversed LZSS stream; reverse byte-for-byte before forward decode.
