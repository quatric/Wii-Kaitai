meta:
  id: rpak
  endian: be
  title: Retro Studios PAK archive (DK Country Returns, Wii)
doc: |
  Retro Studios PAK archive used by Donkey Kong Country Returns (Wii). It has
  a fixed 0x80-byte prelude, an STRG region, an RSHD entry table, and payloads
  whose offsets are relative to the byte immediately after STRG and RSHD.
  A non-zero `compressed` flag identifies a CMPD member; see `cmpd.ksy` for
  the stored/zlib/LZO block contract.

  nintoolbox requires a file of at least 0x84 bytes, at least one non-zero
  section length, 1..0x1000000 entries, a complete table, and every member
  range inside EOF. The scanner rejects the entire archive if any entry range
  is invalid rather than yielding a partial archive.
seq:
  - id: header
    size: 0x48
    doc: Unmodelled prelude bytes through offset 0x47.
  - id: strg_length
    type: u4
    doc: Byte length of the STRG region beginning at 0x80.
  - id: unknown_4c
    size: 4
  - id: rshd_length
    type: u4
    doc: Byte length of the RSHD region immediately following STRG.
  - id: unknown_54
    size: 0x80 - 0x54
  - id: strg
    size: strg_length
    doc: Opaque STRG section retained verbatim; its string semantics are not
      needed to resolve nintoolbox's extracted entries.
  - id: rshd
    type: rshd_t
    size: rshd_length
instances:
  data_base:
    value: 0x80 + strg_length + rshd_length
types:
  rshd_t:
    seq:
      - id: num_entries
        type: u4
        doc: Count of 24-byte resource descriptors.
      - id: entries
        type: entry_t
        repeat: expr
        repeat-expr: num_entries
  entry_t:
    seq:
      - id: compressed
        type: u4
        doc: Non-zero means the payload is a CMPD container.
      - id: magic
        type: u4
        doc: Per-resource type/magic code retained verbatim.
      - id: id_hi
        type: u4
        doc: High half of the resource identifier.
      - id: id_lo
        type: u4
        doc: Low half of the resource identifier.
      - id: data_length
        type: u4
        doc: Stored payload byte length, including CMPD framing when compressed.
      - id: data_ptr
        type: u4
        doc: Offset relative to `data_base`, not an absolute file offset.
    instances:
      body:
        pos: _root.data_base + data_ptr
        size: data_length
        io: _root._io
        doc: Stored resource bytes resolved from the archive-relative range.
