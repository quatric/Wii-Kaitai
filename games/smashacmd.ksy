meta:
  id: smashacmd
  endian: be
  title: Super Smash Bros. 4 ACMD moveset scripts
doc: |
  Super Smash Bros. 4 ACMD moveset script container (game.bin,
  effect.bin, sound.bin, expression.bin), per lib-smashacmd.c
  (ported from Sammi-Husky/Sm4sh-Tools ACMDFile.cs). Byte 4 selects
  endianness: 0x02 little-endian (3DS), 0x00 big-endian (Wii U).
  This definition covers the big-endian (Wii U) case; script bodies
  (per-command opcode/size dictionary, external to the file) are
  not decoded, only exposed as raw spans.
seq:
  - id: magic
    contents: "ACMD"
  - id: version
    type: u4
    doc: Always 2. Low byte at offset 4 doubles as the endianness selector.
  - id: num_actions
    type: u4
  - id: num_commands
    type: u4
  - id: actions
    type: action_entry
    repeat: expr
    repeat-expr: num_actions
types:
  action_entry:
    seq:
      - id: anim_crc
        type: u4
      - id: absolute_offset
        type: s4
    instances:
      script:
        pos: absolute_offset
        size-eos: true
        io: _root._io
