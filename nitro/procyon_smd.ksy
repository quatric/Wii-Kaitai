meta:
  id: procyon_smd
  title: Procyon Studio Standard MIDI Song Data (.smd)
  file-extension: smd
  endian: le
doc: |
  Procyon Studio's `smdl` sequence container (Professor Layton and the
  Diabolical Box, Pokemon Mystery Dungeon). 226 retail files identified
  (15 Layton 2, 211 PMD Sky). A `song` chunk carries music metadata and channel
  assignment and is followed by 4-byte-aligned track sequences (`trk `); the
  file ends with an `eoc ` or `eod ` block. nintoolbox documents only the
  header; chunk bodies are raw.
seq:
  - id: magic
    contents: 'smdl'
  - id: reserved_04
    size: 4
  - id: file_size
    type: u4
  - id: header_rest
    size-eos: true
    doc: '`song` chunk, `trk ` chunks and the trailing `eoc `/`eod ` block.'
