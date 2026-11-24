meta:
  id: mh2_mat
  title: Manhunt 2 material table (mat_wii.bin)
  file-extension: bin
  endian: be
doc: |
  Rockstar Leeds material table (Manhunt 2 `mat_wii.bin`). The file size is
  exactly `4 * H + 200 * N + 4`; the record bytes other than the name are zero
  on all level files.
seq:
  - id: num_header_words
    type: u4
    doc: 64 or 65.
  - id: header_words
    type: u4
    repeat: expr
    repeat-expr: num_header_words
  - id: records_and_trailer
    size-eos: true
types:
  record:
    seq:
      - id: id
        type: u4
      - id: name
        size: 196
        type: strz
        encoding: ASCII
