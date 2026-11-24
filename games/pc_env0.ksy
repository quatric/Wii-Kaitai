meta:
  id: pc_env0
  title: Paws and Claws ENV0 collision archive
  file-extension: bin
  endian: be
doc: |
  `ENV0` collision archive (Paws & Claws - Pet Resort, Wii
  `TPWiiProj/COL/Merged.bin`). Back-to-back chunks, tags `ENV0`..`ENVE`,
  `CAM0`.., `COL0`.., `DOG0`, `CAT0`, ...; each block starts `BCBS` (or `BCAB`
  for the small ones). The BCBS block starts `{"BCBS", u32 offsets[6] ...}`.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_block
        type: u4
      - id: block
        size: len_block
