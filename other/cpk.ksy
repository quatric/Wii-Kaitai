meta:
  id: cpk
  file-extension: cpk
  endian: le
  title: CRIWARE CPK archive
doc: |
  CRIWARE's CPK archive container, as used by many Wii/Wii U/3DS titles
  (this repo's reader was verified against Star Fox Zero, Wii U). A CPK
  is a sequence of "packets": a 4-byte magic, a version/pad word, an
  8-byte payload size, then a payload holding a `@UTF` table (CRI's
  generic schema'd row/column table format, optionally XOR-obfuscated).

  The root `CPK ` packet's UTF table (a single row) carries `TocOffset`,
  `ContentOffset`, `Files` and `Align` fields that locate a `TOC ` packet;
  the TOC's UTF table has one row per archive member with
  `DirName`/`FileName`/`FileSize`/`ExtractSize`/`FileOffset` columns,
  offsets rebased by `min(ContentOffset, TocOffset)`. Payloads whose
  `ExtractSize` differs from `FileSize` are compressed with CRILAYLA.

  The `@UTF` table itself is a fully generic, self-describing schema
  (arbitrary column count/type/flags resolved at run time from a schema
  block ahead of the row data) and is not unrolled into a static struct
  here; only the outer packet framing common to every CPK is modelled.
seq:
  - id: root_packet
    type: packet
types:
  packet:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
        doc: e.g. "CPK ", "TOC ", "ITOC", "ETOC", "GTOC".
      - id: unknown
        type: u4
      - id: payload_size
        type: u8
      - id: payload
        size: payload_size
  utf_table:
    doc: |
      CRIWARE `@UTF` schema'd table header. Column definitions and row
      data follow but are not modelled: their layout depends on the
      per-column type/flag byte read at run time.
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
        valid: '"@UTF"'
      - id: table_size
        type: u4be
      - id: unknown1
        type: u4be
      - id: ofs_rows
        type: u4be
      - id: len_row
        type: u4be
      - id: num_rows
        type: u4be
      - id: ofs_strings
        type: u4be
      - id: len_strings
        type: u4be
      - id: ofs_data
        type: u4be
      - id: ofs_table_name
        type: u4be
      - id: num_columns
        type: u2be
      - id: len_row_check
        type: u2be
