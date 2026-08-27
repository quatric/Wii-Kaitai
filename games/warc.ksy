meta:
  id: warc
  file-extension: warc
  endian: be
  title: Game & Wario WARC archive
doc: |
  Nintendo / Monster Games archive container format used in Game & Wario
  (Wii U). Stores assets (models, textures, layouts, sound, scripts) addressed
  by flat folder name and filename pairs.

  Frequently wrapped in FZIP (ZLIB-based) compression.
seq:
  - id: magic
    contents: "WARC"
    doc: ASCII magic signature 'WARC' (0x57415243)
  - id: dummy1
    type: u4
  - id: zero
    type: u4
  - id: warc_size
    type: u4
  - id: info_size
    type: u4
  - id: num_folders
    type: u2
  - id: num_files
    type: u2
  - id: reserved
    type: u4
    repeat: expr
    repeat-expr: 8
  - id: num_entries
    type: u4
  - id: dummy2
    type: u4
  - id: files
    type: file_entry
    repeat: expr
    repeat-expr: num_files
  - id: entries
    type: entry_record
    repeat: expr
    repeat-expr: num_entries + 1

types:
  file_entry:
    seq:
      - id: dummy_a
        type: u4
        repeat: expr
        repeat-expr: 5
      - id: size
        type: u4
        doc: Size of the file payload in bytes
      - id: dummy_b
        type: u4
      - id: offset
        type: u4
        doc: Absolute byte offset of file payload from start of WARC

  entry_record:
    seq:
      - id: dummy_c
        type: u4
      - id: flags1
        type: u2
      - id: flags2
        type: u2
      - id: dummy_d
        type: u4
      - id: dummy_e
        type: u4
