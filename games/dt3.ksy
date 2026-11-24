meta:
  id: dt3
  title: Heatseeker HS.dt3
  file-extension: dt3
  endian: be
doc: |
  Heatseeker (Wii) `HS.dt3`: a flat archive of 0x200-aligned entries, each a
  0x200-byte header followed by its data padded to the next 0x200 boundary. The
  decimal number in the header does not match the stored length, so an entry
  runs to the next header (PNG members end at `IEND`). Only the header is
  modelled.
seq:
  - id: first_header
    type: entry_header
types:
  entry_header:
    seq:
      - id: name
        size: 0x7c
        type: strz
        encoding: ASCII
        doc: Backslash paths, zero padded.
      - id: number_and_padding
        size: 0x200 - 0x7c
        doc: ASCII decimal number at 0x7c, then zeros.
