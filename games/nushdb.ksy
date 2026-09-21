meta:
  id: nushdb
  file-extension: nushdb
  endian: le
  title: Bandai Namco SSBH compiled-shader container (Super Smash Bros. Ultimate)
doc: |
  SSBH SHDR container. Every pointer is a 64-bit offset relative to the
  field that holds it (SsbhString / SsbhArray / SsbhByteBuffer
  conventions). Each shader's GPU binary is proprietary NVN machine code
  with no public spec, so it is exposed only as an offset+size blob, not
  decoded further.

  Reference: nintoolbox project/src/lib-nushdb.c (DecodeNUSHDB_Text),
  itself following ultimate-research/ssbh_lib's shdr.rs (Shdr::V12).
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"HBSS"', '"SSBH"']
  - id: unk_08
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"RDHS"', '"SHDR"']
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: shaders
    type: ssbh_array(_io.pos)
instances:
  shader_list:
    pos: shaders.ofs_absolute
    type: shader
    repeat: expr
    repeat-expr: shaders.count
    if: shaders.ofs_relative != 0
types:
  ssbh_array:
    doc: One SsbhArray field -- u8 relative offset (relative to its own position) + u8 count.
    params:
      - id: field_pos
        type: u8
    seq:
      - id: ofs_relative
        type: s8
      - id: count
        type: u8
    instances:
      ofs_absolute:
        value: field_pos + ofs_relative

  ssbh_string:
    doc: SsbhString field -- u8 relative offset (relative to its own position) to a NUL-terminated string.
    params:
      - id: field_pos
        type: u8
    seq:
      - id: ofs_relative
        type: s8
    instances:
      value:
        pos: field_pos + ofs_relative
        type: strz
        encoding: UTF-8
        if: ofs_relative != 0

  shader:
    doc: One compiled shader entry, 0x38 bytes.
    seq:
      - id: name
        type: ssbh_string(_io.pos)
      - id: shader_stage
        type: u4
        enum: shader_stage
      - id: unk3
        type: u4
        doc: Always 2 on retail files.
      - id: shader_binary
        type: ssbh_byte_buffer(_io.pos)
      - id: binary_size
        type: u8
        doc: Duplicate of shader_binary's own count.
      - id: padding
        size: 16
  ssbh_byte_buffer:
    doc: SsbhByteBuffer field -- u8 relative offset + u8 count, the compiled NVN GPU binary blob.
    params:
      - id: field_pos
        type: u8
    seq:
      - id: ofs_relative
        type: s8
      - id: count
        type: u8
    instances:
      data:
        pos: field_pos + ofs_relative
        size: count
        if: ofs_relative != 0
enums:
  shader_stage:
    0: vertex
    3: geometry
    4: fragment
    5: compute
