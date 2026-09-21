meta:
  id: gpkg
  file-extension: pkg
  endian: be
  title: Gorilla Games "GPKG" package (Bonsai Barber, WiiWare)
doc: |
  Whole-file zlib stream (Gorilla Games' WiiWare titles). Once inflated,
  a 0x14-byte header holds a data offset and the member count, followed
  by one 0x28-byte entry (32-byte name, offset, size) per member. Entry
  offsets are relative to `decompressed_size - data_off`, i.e. the start
  of the data area. Ported from lib-gpkg.c's `ScanGPKG`/`CreateGPKG`.
seq:
  - id: body
    size-eos: true
    process: zlib
    type: gpkg_body
    doc: >-
      Entire package payload, inflated as one zlib stream.  The scanner first
      requires a zlib-looking 0x78 lead byte and then rejects an inflated
      stream shorter than the fixed 0x14-byte header.
types:
  gpkg_body:
    seq:
      - id: unknown_0
        type: u4
        doc: Unknown leading header word at offset 0x00; the writer leaves it zero.
      - id: data_off
        type: u4
        doc: |
          Distance from the end of the decompressed stream back to the
          start of the data area; entry offsets are relative to that point.
      - id: reserved
        type: u4
        doc: >-
          Required-zero reserved word.  The scanner rejects a package when it
          is non-zero; the writer emits zero.
      - id: unknown_c
        type: u4
        doc: Unknown header word at offset 0x0c; the writer leaves it zero.
      - id: num_entries
        type: u4
        doc: >-
          Number of 0x28-byte member records.  The scanner accepts
          1..0x100000 and requires the complete table within the inflated
          stream.
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: num_entries
    instances:
      base_off:
        value: _io.size - data_off
        doc: >-
          Absolute start of the data area.  data_off is a distance measured
          backward from EOF, so this subtraction—not data_off itself—is the
          base for every entry offset.
      entry_table_end:
        value: 0x14 + num_entries * 0x28
        doc: First byte after the fixed-size entry table.
      data_area_start:
        value: base_off
        doc: >-
          First member-data byte.  nintoolbox's writer aligns this up from
          entry_table_end to 0x20 and aligns each following member likewise.
    types:
      entry:
        seq:
          - id: name
            type: str
            size: 0x20
            encoding: ASCII
            doc: NUL-padded member name (basename only; no directory component).
          - id: ofs_body
            type: u4
            doc: Offset relative to `base_off` (start of the data area).
          - id: len_body
            type: u4
            doc: Member byte length.  The scanner skips an individual record
              whose resolved range exceeds the decompressed stream.
        instances:
          body:
            pos: _parent.base_off + ofs_body
            size: len_body
            doc: Raw member bytes at the resolved data-area-relative range.
