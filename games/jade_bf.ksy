meta:
  id: jade_bf
  title: Ubisoft BIG bigfile version 42 (.bf)
  file-extension: bf
  endian: le
doc: |
  Ubisoft `BIG` bigfile (`*.bf`, version 42; Prince of Persia: The Forgotten
  Sands `djinn_bin_wii.bf`, Avatar, Shaun White Skateboarding). A table of
  `{u32 key, u32 offset}` pairs sits at 0x38 (the first pair is a 0xFFFFFFFF/0
  sentinel). Records are stored back to back: `{u32 size, payload, 4 trailer
  bytes}` so a record runs to the next offset. Names are hashes. How the sentinel
  relates to `num_files` is not stated, so the pair table is not declared.
seq:
  - id: magic
    contents: ['BIG', 0]
  - id: version
    type: u4
    doc: 42.
  - id: num_files
    type: u4
  - id: four
    type: u4
