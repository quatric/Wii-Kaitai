meta:
  id: sousound
  title: LucasArts MONSTER.SOU voice file (Indiana Jones Staff of Kings)
  file-extension: sou
  endian: be
doc: |
  "SOU " + 0, a "VCTL" chunk (u32 BE size, offset table), then thousands of
  Creative Voice Files ("Creative Voice File\x1a", 26-byte header, blocks {u8
  type, u24le size}) back to back. Type 1 blocks (u8 frequency divisor, u8 codec
  0 = 8-bit unsigned PCM) and type 2 continuations join into mono 8-bit audio
  (rate = 1000000 / (256 - divisor)).
seq:
  - id: magic
    contents: ["SOU ", 0]
  - id: vctl_tag
    contents: VCTL
  - id: vctl_size
    type: u4
  - id: vctl_table
    size: vctl_size - 8
  - id: rest
    size-eos: true
types:
  voc_block:
    seq:
      - id: type
        type: u1
      - id: size
        type: b24le
      - id: body
        size: size
        if: type != 0
