meta:
  id: cs12
  title: CS12 sound container (Emergency Heroes)
  endian: le
doc: |
  "CS12", a few LE words (page table) then 0x800-aligned "CHNK" blocks {"CHNK",
  u32 size, u32 count, u32 3, "SGSB", ...}. Sound blocks carry "MDWI" at +0x20:
  u32 at +0x44 = DSP-ADPCM bytes, u16 at +0x48 = rate, 16 BE s16 coefficients
  at +0x80, mono DSP-ADPCM frames at +0xf0.
seq:
  - id: magic
    contents: CS12
  - id: rest
    size-eos: true
types:
  chnk:
    seq:
      - id: tag
        contents: CHNK
      - id: size
        type: u4
      - id: count
        type: u4
      - id: three
        type: u4
      - id: sgsb
        size: 4
      - id: body
        size: size - 20
