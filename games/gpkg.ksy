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
types:
  gpkg_body:
    seq:
      - id: unknown_0
        type: u4
      - id: data_off
        type: u4
        doc: |
          Distance from the end of the decompressed stream back to the
          start of the data area; entry offsets are relative to that point.
      - id: reserved
        type: u4
        doc: Always 0 in every known sample.
      - id: unknown_c
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: num_entries
    instances:
      base_off:
        value: _io.size - data_off
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
        instances:
          body:
            pos: _parent.base_off + ofs_body
            size: len_body
