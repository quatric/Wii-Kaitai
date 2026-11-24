meta:
  id: swd
  title: Procyon Studio swdb sound bank
  file-extension: swd
  endian: be
doc: |
  Arc Rise Fantasia (Wii). Chunks "wavi", "prgi", "kgrp", "pcmd", "eod ". The
  pcmd chunk holds complete DSP-ADPCM files back to back.
seq:
  - id: magic
    contents: swdb
  - id: unk4
    size: 4
  - id: file_size
    type: u4
  - id: unk0c
    size: 0x14
  - id: name
    size: 0x20
    type: strz
    encoding: ASCII
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: unk4
        type: u4
      - id: unk8
        type: u4
      - id: length
        type: u4
      - id: data
        size: length
