meta:
  id: mssbnk
  title: RAD Miles Sound System bank (RADBFile, .mssbnk)
  file-extension: mssbnk
  endian: le
doc: |
  Fit in Six. A database file holding sound resources behind a string/metadata
  directory. Embedded RIFF/WAVE (Microsoft IMA ADPCM, tag 0x11) effects are
  carved by RIFF size; music streams use RAD Audio ("RADA").
seq:
  - id: magic
    size: 8
    doc: '"RADBFile".'
  - id: rest
    size-eos: true
