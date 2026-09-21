meta:
  id: saltparam
  endian: be
  title: Super Smash Bros. 4 SALT parameter file
doc: |
  Super Smash Bros. 4 SALT parameter file (fighter_param.bin, stage
  params), per lib-saltparam.h. Reference:
  Sammi-Husky/Sm4sh-Tools SALT/Params/ParamFile.cs (MIT).
  Values before the first group form a flat list; every group holds
  `entry_count` entries of equal size (that equal-size invariant is
  not itself checkable statically, so groups are parsed as a plain
  repeated value stream here).
seq:
  - id: magic
    contents: [0xff, 0xff]
  - id: reserved
    size: 6
  - id: values
    type: value_t
    repeat: eos
types:
  value_t:
    seq:
      - id: kind
        type: u1
        enum: kind_t
      - id: body
        type:
          switch-on: kind
          cases:
            kind_t::s8: s1
            kind_t::u8: u1
            kind_t::s16: s2
            kind_t::u16: u2
            kind_t::s32: s4
            kind_t::u32: u4
            kind_t::f32: f4
            kind_t::string: string_t
            kind_t::group: group_t
  string_t:
    seq:
      - id: length
        type: s4
      - id: text
        type: str
        size: length
        encoding: UTF-8
  group_t:
    doc: Marks the start of a new value group; entry_count entries of equal size follow.
    seq:
      - id: entry_count
        type: s4
enums:
  kind_t:
    1: s8
    2: u8
    3: s16
    4: u16
    5: s32
    6: u32
    7: f32
    8: string
    0x20: group
