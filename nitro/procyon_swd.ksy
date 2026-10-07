meta:
  id: procyon_swd
  title: Procyon Studio Sound Wave Data (.swd)
  file-extension: swd
  endian: le
doc: |
  Procyon Studio's `swdl` sound-wave container, the instrument/sample bank of
  Yasunori Mitsuda's sound studio used across Level-5 titles (Professor Layton
  and the Diabolical Box, Inazuma Eleven) and Chunsoft titles (Pokemon Mystery
  Dungeon Explorers of Time/Darkness/Sky). 385 retail files identified (82
  Layton 2, 303 PMD Sky).

  nintoolbox documents the header and chunk sections only: `wavi` (wave
  parameters and sample properties), `prgi` (program / instrument
  definitions), `kgrp` (keygroup mappings) and `pcmd` (raw ADPCM/PCM sample
  stream), followed by a trailing `eod ` block. Each chunk's internal layout is
  not described by nintoolbox, so chunk bodies are raw.
seq:
  - id: magic
    contents: 'swdl'
  - id: reserved_04
    size: 4
  - id: file_size
    type: u4
  - id: header_rest
    size-eos: true
    doc: |
      Remainder of the header and the `wavi` / `prgi` / `kgrp` / `pcmd` chunk
      sections, ending with `eod ` (`eod \0\0\x15\x04\x10\0\0\0\0\0\0\0`).
