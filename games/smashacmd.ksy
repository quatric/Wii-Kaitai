meta:
  id: smashacmd
  endian: be
  title: Super Smash Bros. 4 ACMD moveset scripts
doc: |
  Super Smash Bros. 4 ACMD moveset script container (game.bin,
  effect.bin, sound.bin, expression.bin), per lib-smashacmd.c
  (ported from Sammi-Husky/Sm4sh-Tools ACMDFile.cs). The 32-bit version
  is always 2: on disk it is 00 00 00 02 for Wii U big-endian and
  02 00 00 00 for 3DS little-endian. The selected byte order applies
  to counts, CRCs, offsets, and script words.

  There are num_actions eight-byte descriptors after the 16-byte header.
  Each script spans from its absolute offset to the next descriptor's
  offset, or to EOF for the last descriptor. Equal adjacent offsets
  describe an empty script slot. Nonempty scripts must end in the
  32-bit terminator 0x5766f889, in the file's byte order. The action
  CRC is the animation-name identifier; num_commands is a reported
  total, not a byte length for any one script. Individual command
  sizes depend on an external opcode dictionary and are not decoded.

  nintoolbox requires 1..100000 actions, a complete descriptor table,
  four-byte-aligned nondecreasing script offsets beginning no earlier
  than the table end, in-file script boundaries, and a valid terminator
  on each nonempty span. This schema exposes the spans but does not
  enforce all of those consistency rules.
seq:
  - id: magic
    contents: "ACMD"
  - id: version_be_probe
    type: u4be
    valid:
      any-of: [2, 0x02000000]
    doc: Version 2 in one of two byte orders; selects the remaining fields.
  - id: content
    type: content_t(is_le)
instances:
  is_le:
    value: version_be_probe == 0x02000000
    doc: True for 3DS little-endian files; false for Wii U big-endian files.
types:
  content_t:
    params:
      - id: little_endian
        type: bool
    meta:
      endian:
        switch-on: little_endian
        cases:
          true: le
          false: be
    seq:
      - id: num_actions
        type: u4
        doc: Number of eight-byte action descriptors.
      - id: num_commands
        type: u4
        doc: Reported total command count across scripts.
      - id: actions
        type: action_entry(_index, little_endian)
        repeat: expr
        repeat-expr: num_actions
  action_entry:
    params:
      - id: index
        type: u4
      - id: little_endian
        type: bool
    meta:
      endian:
        switch-on: little_endian
        cases:
          true: le
          false: be
    seq:
      - id: anim_crc
        type: u4
        doc: Animation-name CRC identifying this script slot.
      - id: absolute_offset
        type: u4
        doc: Absolute script start, four-byte aligned in recognized files.
    instances:
      script:
        io: _root._io
        pos: absolute_offset
        size: '(index + 1 < _parent.num_actions ? _parent.actions[index + 1].absolute_offset : _root._io.size) - absolute_offset'
        doc: Raw script words through the next offset, including the terminator if nonempty.
