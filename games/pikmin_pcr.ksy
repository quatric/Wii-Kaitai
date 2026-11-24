meta:
  id: pikmin_pcr
  title: Pikmin 1 particle generator (.pcr)
  file-extension: pcr
  endian: be
doc: |
  "1-02" tag; u16 offset of the generator parameter block at +4. The block
  (zen::particleGenerator::pmSetDDF) is not modelled; the billboard / oriented
  draw header in front of it is kept raw.
seq:
  - id: tag
    size: 4
  - id: block_offset
    type: u2
  - id: rest
    size-eos: true
