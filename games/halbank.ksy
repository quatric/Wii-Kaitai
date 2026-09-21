meta:
  id: halbank
  file-extension: dat
  endian: be
  title: HAL Laboratory "A2" bank archive (Kirby Air Ride)
doc: |
  Named-blob archive used by Kirby Air Ride's 2D/UI ".dat" banks
  (distinct from the sysdolphin object graphs also shipped as ".dat").
  There is no magic; the format is only identifiable structurally (the
  string pool immediately follows the pair table). Blobs carry no length
  of their own -- each one runs up to whichever payload starts next, or
  to EOF for the last one -- so `data_size` here is computed the same way
  lib-halbank.c's `ScanHALBank` does, not read from the file.

  Entries have no type tag either: an entry's kind, and for textures its
  pixel/palette format and dimensions, are encoded in its name, e.g.
  "shadow.RGBA8_64_64.tex" or "arrow_r.12_12_12_12.C8RGB5A3_24_24.tex"
  (format[+palette]_width_height, with an optional leading 9-slice-margin
  field). That name grammar is not modeled here since it is text parsing,
  not binary structure; see lib-halbank.c's `parse_tex_name`.
seq:
  - id: file_size
    type: u4
    doc: Either 0 or the exact file size; both spellings occur in retail files.
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: ofs_name
        type: u4
        doc: Absolute offset of the NUL-terminated entry name.
      - id: ofs_body
        type: u4
        doc: Absolute offset of the payload; no length is stored alongside it.
    instances:
      name:
        io: _root._io
        pos: ofs_name
        type: strz
        encoding: ASCII
