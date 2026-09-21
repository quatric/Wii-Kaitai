meta:
  id: narc
  endian: le
  title: Nintendo DS NARC file archive
doc: |
  Nintendo DS "NARC" archive, as read by ScanNARC() in lib-narc.c.
  A small chunk-based container: a 16-byte file header, then three
  sub-chunks back to back -- BTAF/FATB (file allocation table),
  BTNF/FNTB (directory/file name table), and GMIF/FIMG (the raw file
  data blob). Chunk order in retail files is BTAF, BTNF, GMIF, but the
  reference reader walks chunks by tag rather than assuming that order.
  Both little- and big-endian variants exist ("NARC"/0xFFFE little,
  "CRAN" big); this definition covers the little-endian retail shape.
seq:
  - id: magic
    contents: "NARC"
  - id: bom
    type: u2
    doc: 0xFFFE for little-endian files.
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: n_chunks
    type: u2
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: chunk_size
        type: u4
      - id: body
        size: chunk_size - 8
        type:
          switch-on: magic
          cases:
            '"BTAF"': fatb_body
            '"FNTB"': btnf_body
  fatb_body:
    seq:
      - id: n_files
        type: u4
      - id: reserved
        type: u2
      - id: entries
        type: fat_entry
        repeat: expr
        repeat-expr: n_files
  fat_entry:
    seq:
      - id: start_offset
        type: u4
        doc: Relative to the start of the FIMG chunk's data (after its 8-byte header).
      - id: end_offset
        type: u4
  btnf_body:
    seq:
      - id: root_sub_offset
        type: u4
      - id: root_first_file_id
        type: u2
      - id: n_dirs
        type: u2
        doc: Masked with 0x0FFF by the reader; total directory count.
