meta:
  id: cpk
  file-extension: cpk
  endian: be
  title: CRIWARE CPK archive
doc: |
  CRIWARE's general-purpose asset archive, built on CRI's "UTF" columnar
  table format. This models the subset actually read by this codebase's
  scanner (lib-cpk.c, ported from esperknight/CriPakTools' `CPK.cs`, and
  verified against retail Star Fox Zero Wii U archives): a `CPK ` packet
  holding one UTF table (the archive header row), and a `TOC ` packet
  -- located via that header's `TocOffset` field -- holding one UTF row
  per archive member. `ITOC`-only archives (no `TOC ` packet) are not
  handled by the scanner and are not modeled here; the `ETOC` packet,
  when present, is also not read (member paths already come from `TOC `).

  Every packet is framed the same way: a 4-byte magic, a little-endian
  s4 (purpose not used by the scanner), a little-endian u8 payload size,
  then that many payload bytes.

  A UTF table payload normally opens with the magic `@UTF`; if it does
  not, the whole payload is XOR-obfuscated with a rolling multiplicative
  keystream (seed 0x655f, multiplier 0x4115 per byte) that is not itself
  a binary *structure* and is therefore not modeled in Kaitai -- see
  `cpk_utf_parse()` in lib-cpk.c for the exact keystream. This .ksy
  assumes an already-decrypted `@UTF` payload.

  The UTF header gives a row/string pool layout (`rows_offset`/
  `strings_offset`, both relative to the byte after the size field, i.e.
  +8 from the payload start) and a column count/row length/row count,
  followed by that many column descriptors. Each column descriptor is
  normally a 1-byte flags field plus a big-endian u4 string-pool offset
  for the column's name (5 bytes); if the flags byte reads as 0, the
  descriptor is instead 9 bytes -- 4 padding/unused bytes, then the real
  1-byte flags and 4-byte name offset -- a quirk this codebase's reader
  reproduces byte for byte without further explanation.

  Only "PERROW" columns (flags & 0xf0 == 0x50) actually store data
  per row; the scanner looks specific columns up by name
  (`TocOffset`/`ContentOffset`/`Files`/`Align`/`EtocOffset` on the
  header table; `DirName`/`FileName`/`FileSize`/`ExtractSize`/
  `FileOffset` on the TOC table) rather than assuming a fixed column
  order, so row data here is left as a raw `row_length`-byte blob per
  row instead of being decoded column-by-column.

  A member's absolute file offset is `FileOffset + min(ContentOffset,
  TocOffset)` (or `+ TocOffset` when `ContentOffset` is absent/greater).
  When a member's `ExtractSize` differs from its `FileSize`, the stored
  bytes are CRILAYLA-compressed (magic `CRILAYLA`, a 16-byte header
  giving the decompressed size and an offset to a trailing 0x100-byte
  raw header copy, then a backwards LZ-style bitstream) -- an
  algorithmic codec with no further static container structure, so it is
  not modeled here beyond its own small header.
seq:
  - id: header_packet
    type: packet
    doc: The `CPK ` packet; its payload is the archive header UTF table.
types:
  packet:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: unk
        type: s4le
      - id: payload_size
        type: u8le
      - id: payload
        size: payload_size
        type: utf_table
  utf_table:
    seq:
      - id: magic
        contents: "@UTF"
      - id: unk1
        type: u4
        doc: Not interpreted by the scanner.
      - id: ofs_rows_raw
        type: u4
        doc: Row-data offset, relative to `_io.pos` at the start of this field's section (add 8 for the absolute in-payload offset).
      - id: ofs_strings_raw
        type: u4
        doc: String-pool offset, relative the same way as `ofs_rows_raw`.
      - id: unk2
        size: 8
        doc: Not interpreted by the scanner.
      - id: num_columns
        type: u2
      - id: row_length
        type: u2
      - id: num_rows
        type: u4
      - id: columns
        type: column
        repeat: expr
        repeat-expr: num_columns
    instances:
      ofs_rows:
        value: ofs_rows_raw + 8
      ofs_strings:
        value: ofs_strings_raw + 8
      rows:
        pos: ofs_rows
        size: row_length
        repeat: expr
        repeat-expr: num_rows
    types:
      column:
        seq:
          - id: flags_raw
            type: u1
          - id: pad
            size: 4
            if: flags_raw == 0
            doc: Only present when `flags_raw` reads as 0; the real flags/name follow it.
          - id: flags2
            type: u1
            if: flags_raw == 0
          - id: ofs_name
            type: u4
        instances:
          flags:
            value: 'flags_raw == 0 ? flags2 : flags_raw'
          is_perrow:
            value: (flags & 0xf0) == 0x50
          storage_type:
            value: flags & 0x0f
          name:
            io: _root._io
            pos: _parent._parent.ofs_strings + ofs_name
            type: strz
            encoding: ASCII
  crilayla_header:
    doc: Header of a CRILAYLA-compressed member payload; the bitstream body itself is algorithmic and not modeled here.
    seq:
      - id: magic
        contents: "CRILAYLA"
      - id: uncompressed_size
        type: u4le
      - id: ofs_uncompressed_header
        type: u4le
        doc: Offset (from immediately after this field) of a trailing 0x100-byte copy of the original, uncompressed header.
