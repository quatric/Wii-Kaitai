meta:
  id: bcab_chunks
  title: BCAB collision chunk list
  file-extension: bin
  endian: be
doc: |
  `BCAB` collision chunk list (Paws & Claws, Wii
  `TPWiiProj/COL/merged_cs|dirt|hoofs.bin`). A chain of chunks that ends
  exactly at EOF; every body is the tag `BCAB` followed by `(size - 4) / 4`
  floats (10 normally, 11 for `DRTC`).
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: name
        type: str
        size: 4
        encoding: ASCII
        doc: '`DOGA`, `DRTC`, `H_HL`, ...'
      - id: len_body
        type: u4
      - id: body
        size: len_body
