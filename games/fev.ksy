meta:
  id: fev
  title: FMOD Designer event file (.fev, "FEV1")
  file-extension: fev
  endian: le
doc: |
  FMOD Ex games. u32 version, u32 sizes, u32 count, project name... Records
  between the strings are version dependent; strings are {u32 length including
  the NUL, chars, NUL}: project, bank, category, event group, event and wave
  bank names.
seq:
  - id: magic
    contents: FEV1
  - id: version
    type: u4
  - id: sizes
    type: u4
  - id: count
    type: u4
  - id: rest
    size-eos: true
types:
  lp_string:
    seq:
      - id: length
        type: u4
      - id: text
        size: length
        type: strz
        encoding: ASCII
