meta:
  id: apak
  file-extension: apak
  title: Nintendo APAK archive
doc: |
  A flat archive with a 24-byte header and fixed 64-byte entries. Written
  by this tool always as big-endian version 5; endianness is detected on
  read from the version field at offset 6, which reads as big-endian 5
  when the whole file is big-endian.
seq:
  - id: magic
    contents: "APAK"
  - id: unknown0
    size: 2
  - id: version_be_probe
    type: u2be
    doc: Read big-endian to detect overall endianness; 5 means the file is big-endian.
  - id: content
    type:
      switch-on: version_be_probe
      cases:
        5: body(false)
        _: body(true)
types:
  body:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: num_files
        type: u4
      - id: unknown1
        type: u4
      - id: len_file_info
        type: u4
        doc: Byte size of the entry table (num_files * 64).
      - id: unknown2
        type: u4
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: num_files
    types:
      entry:
        seq:
          - id: unknown0
            size: 4
          - id: ofs_body
            type: u4
          - id: len_body
            type: u4
          - id: unknown1
            size: 20
          - id: name
            type: strz
            encoding: ASCII
            size: 32
        instances:
          body:
            io: _root._io
            pos: ofs_body
            size: len_body
