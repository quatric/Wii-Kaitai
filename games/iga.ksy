meta:
  id: iga
  title: Alchemy/Vicarious Visions IGA archive (Skylanders)
  file-extension: arc
  endian: le
doc: |
  Alchemy / Vicarious Visions "IGA" archive (`.arc`; Skylanders on Wii),
  verified on retail Spyro's Adventure archives. Versions 4 (Skylanders) and 2
  (Madagascar: Escape 2 Africa; also `.bld` / `.pak`) share this layout.

  An entry whose `flags & 0xf0000000 == 0x10000000` is a chunked-LZMA member
  and `size` is then the *unpacked* size. The member is a series of
  0x800-aligned chunks (see `lzma_chunk`), each unpacking to 0x8000 bytes (the
  last fewer): `u2` big-endian stream length, 5 LZMA property bytes
  (`props[0] < 225`, dictionary `00 80 00 00`) and the LZMA1 stream. A chunk
  that did not compress is stored as is, without a header, at the same
  alignment.

  After the 0x30-byte header come `count` sorted name hashes, then `count`
  `{offset, size, flags}` records (`flags == -1` means stored). At
  `names_offset` is a `u4 name_offset[count]` array (relative to
  `names_offset`) pointing into the string pool that follows; entry *i* uses
  name *i*.
seq:
  - id: magic
    contents: ['IGA', 0x1a]
  - id: version
    type: u4
    doc: 4 (Skylanders) or 2 (Madagascar 2).
    valid:
      any-of: [4, 2]
  - id: toc_size
    type: u4
  - id: count
    type: u4
  - id: unknown_10
    type: u4
  - id: unknown_14
    type: u4
  - id: names_offset
    type: u4
  - id: names_size
    type: u4
  - id: reserved
    size: 16
  - id: name_hashes
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Sorted.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
instances:
  name_offsets:
    pos: names_offset
    type: u4
    repeat: expr
    repeat-expr: count
    doc: Relative to `names_offset`.
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: flags
        type: s4
        doc: -1 = stored.
    instances:
      is_chunked_lzma:
        value: (flags & 0xf0000000) == 0x10000000
      body:
        pos: offset
        size: size
        io: _root._io
        if: not is_chunked_lzma
  lzma_chunk:
    doc: One compressed chunk of a chunked-LZMA member.
    seq:
      - id: stream_length
        type: u2be
      - id: props
        size: 5
      - id: stream
        size: stream_length
