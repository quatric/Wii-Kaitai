meta:
  id: fmod_names
  title: FMOD Designer event name table (FiveMinFit.fmod)
  file-extension: fmod
  endian: be
doc: |
  10 Minute Solution (Wii, Europe) `<lang>/FiveMinFit.fmod` FMOD Designer event
  name table. Strings are `{u16 length in characters, UTF-16BE characters}`:
  the project file name (`FiveMinFit.fev`), a u16 count and that many name
  components (event groups, banks, events). A binary tail of about 30 KB
  (event / group records indexing the strings) follows and is not decoded.
seq:
  - id: zero
    size: 8
  - id: project_name
    type: lstr
  - id: num_names
    type: u2
  - id: names
    type: lstr
    repeat: expr
    repeat-expr: num_names
  - id: binary_tail
    size-eos: true
types:
  lstr:
    seq:
      - id: len_chars
        type: u2
      - id: text
        type: str
        size: len_chars * 2
        encoding: UTF-16BE
