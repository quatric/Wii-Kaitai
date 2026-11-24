meta:
  id: cpf_crs
  title: Cabela's streams package (.crs)
  file-extension: crs
  endian: le
doc: |
  Cabela's (Fun Labs / Activision, Wii) `streams/*.crs`. The data is a run of
  blocks `{u32 size | 0x80000000 when LZO1X-compressed (stored otherwise),
  payload}`. `.wis` sounds are DSP-ADPCM files.
seq:
  - id: magic
    contents: '!CPF'
  - id: version
    type: u4
    doc: 0x180100.
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: one
        type: u4
      - id: time
        type: u4
      - id: date
        type: u4
      - id: len_memory
        type: u4
      - id: len_unpacked
        type: u4
      - id: data_offset
        type: u4
      - id: num_blocks
        type: u4
      - id: name_hash
        type: u4
      - id: name
        size: 260
        type: strz
        encoding: ASCII
        doc: Backslash paths.
