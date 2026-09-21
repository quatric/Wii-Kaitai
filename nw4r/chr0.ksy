meta:
  id: chr0
  file-extension: chr0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R CHR0 bone animation
doc: |
  Animates a model's skeleton. Each entry is named after a bone of a
  sibling MDL0 and carries up to nine animated scalar channels -- scale
  XYZ, rotation XYZ and translation XYZ. Every channel is independently
  either "fixed" (a single constant float) or a track of keyframes in one
  of six shared encodings.

  A 32-bit `code` word per entry selects, per channel group (scale,
  rotation, translation), whether the group is present at all, whether it
  is isotropic (one shared value/track for all three axes instead of
  three independent ones), which axes are fixed, and which of the six
  track encodings the group's tracks use:

    I4  : 16-byte header + 4 bytes/key,  quantized, indexed
    I6  : 16-byte header (8 for version < 4) + 6 bytes/key, quantized, indexed
    I12 : 8-byte header + 12 bytes/key,  three raw floats, indexed
    L1  : 8-byte header + 1 byte/frame,  quantized, dense (no explicit index)
    L2  : 8-byte header + 2 bytes/frame, quantized, dense
    L4  : no header + 4 bytes/frame,     raw float, dense

  Quantized formats reconstruct a value as `base + raw * step`, both
  carried in the track header. Dense ("linear") formats store one entry
  per frame and need the animation's total frame count
  (`num_frames + (loop ? 1 : 0)`) to know how many entries to read, since
  they carry no key count of their own.

  The exact bit position of the per-group format field within `code`
  shifts between version 3 and versions 4/5; see `rot_format_shift`.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: s4
    doc: Offset from the start of this CHR0 to the bone resource group.
  - id: ofs_user_data
    type: s4
    if: header.version == 5
  - id: ofs_name
    type: s4
  - id: ofs_orig_path
    type: s4
  - id: num_frames
    type: u2
  - id: num_entries
    type: u2
  - id: loop
    type: u4
  - id: scaling_rule
    type: u4
    doc: NW4R scaling rule, preserved verbatim by the encoder.
instances:
  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0
  orig_path:
    pos: ofs_orig_path - 4
    type: pooled_string
    if: ofs_orig_path != 0
  frame_limit:
    value: 'num_frames + (loop != 0 ? 1 : 0)'
    doc: Frame count including the extra loop frame; needed by dense tracks.
  rot_format_shift:
    value: 'header.version < 4 ? 25 : 27'
    doc: |
      Bit position of the rotation group's format field. The scale
      format field sits 2 bits below it, translation's 3 bits above it.
  group:
    pos: ofs_data
    type: resource_group(ofs_data)
    if: ofs_data != 0
types:
  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII

  resource_group:
    doc: Standard BRRES resource group -- entry 0 is a sentinel, excluded from `num_entries`.
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: len_group
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: resource_entry(base_ofs)
        repeat: expr
        repeat-expr: num_entries + 1

  resource_entry:
    doc: One lookup-tree record; `ofs_data` leads to the actual bone entry.
    params:
      - id: base_ofs
        type: s4
    seq:
      - id: id
        type: u2
      - id: reserved
        type: u2
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ofs_name
        type: s4
      - id: ofs_data
        type: s4
    instances:
      name:
        pos: base_ofs + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0
      entry:
        pos: base_ofs + ofs_data
        type: chr0_entry(base_ofs + ofs_data)
        if: ofs_data != 0

  chr0_entry:
    doc: |
      One animated bone. `ofs_name` here is relative to the start of this
      entry, independent of the lookup record's own name pointer. The
      channel-group fields below are physically present only when their
      group's "exists" bit is set in `code`, and collapse from three
      slots (X, Y, Z) to one when the group's "isotropic" bit is also
      set -- absent fields occupy zero bytes.
    params:
      - id: self_pos
        type: s4
        doc: Absolute file offset of this entry's first byte (the `ofs_name` field).
    seq:
      - id: ofs_name
        type: s4
      - id: code
        type: u4
        doc: |
          Raw code word. Bit 4/5/6 = scale/rot/trans isotropic; bit
          13..21 = scale/rot/trans X/Y/Z fixed; bit 22/23/24 =
          scale/rot/trans group exists; bits above that select each
          group's track format (see `rot_format_shift` on the CHR0 root).
      - id: scale_iso
        type: channel_slot(_root.rot_format_shift - 2 & 3, (code >> 15 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 22 & 1) != 0 and (code >> 4 & 1) != 0
      - id: scale_x
        type: channel_slot(_root.rot_format_shift - 2 & 3, (code >> 13 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 22 & 1) != 0 and (code >> 4 & 1) == 0
      - id: scale_y
        type: channel_slot(_root.rot_format_shift - 2 & 3, (code >> 14 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 22 & 1) != 0 and (code >> 4 & 1) == 0
      - id: scale_z
        type: channel_slot(_root.rot_format_shift - 2 & 3, (code >> 15 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 22 & 1) != 0 and (code >> 4 & 1) == 0
      - id: rot_iso
        type: channel_slot(_root.rot_format_shift & 7, (code >> 18 & 1) != 0, self_pos, _root.frame_limit, _root.header.version < 4)
        if: (code >> 23 & 1) != 0 and (code >> 5 & 1) != 0
      - id: rot_x
        type: channel_slot(_root.rot_format_shift & 7, (code >> 16 & 1) != 0, self_pos, _root.frame_limit, _root.header.version < 4)
        if: (code >> 23 & 1) != 0 and (code >> 5 & 1) == 0
      - id: rot_y
        type: channel_slot(_root.rot_format_shift & 7, (code >> 17 & 1) != 0, self_pos, _root.frame_limit, _root.header.version < 4)
        if: (code >> 23 & 1) != 0 and (code >> 5 & 1) == 0
      - id: rot_z
        type: channel_slot(_root.rot_format_shift & 7, (code >> 18 & 1) != 0, self_pos, _root.frame_limit, _root.header.version < 4)
        if: (code >> 23 & 1) != 0 and (code >> 5 & 1) == 0
      - id: trans_iso
        type: channel_slot(_root.rot_format_shift + 3 & 3, (code >> 21 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 24 & 1) != 0 and (code >> 6 & 1) != 0
      - id: trans_x
        type: channel_slot(_root.rot_format_shift + 3 & 3, (code >> 19 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 24 & 1) != 0 and (code >> 6 & 1) == 0
      - id: trans_y
        type: channel_slot(_root.rot_format_shift + 3 & 3, (code >> 20 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 24 & 1) != 0 and (code >> 6 & 1) == 0
      - id: trans_z
        type: channel_slot(_root.rot_format_shift + 3 & 3, (code >> 21 & 1) != 0, self_pos, _root.frame_limit, false)
        if: (code >> 24 & 1) != 0 and (code >> 6 & 1) == 0
    instances:
      name:
        pos: self_pos + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0

  channel_slot:
    doc: |
      One 4-byte channel slot: a big-endian float when `is_fixed`, else
      an offset (relative to the owning entry's `self_pos`) to a `track`.
      Scale/translation format fields that read `BANIM_NONE` (0) fall
      back to I12 in practice (see lib-chr.c); that fallback is not
      reproduced here.
    params:
      - id: format
        type: u4
      - id: is_fixed
        type: bool
      - id: self_pos
        type: s4
      - id: frame_limit
        type: u4
      - id: short_i6_header
        type: bool
    seq:
      - id: raw
        type: u4
    instances:
      as_float:
        pos: _io.pos - 4
        type: f4
      as_offset:
        pos: _io.pos - 4
        type: u4
      track:
        io: _root._io
        pos: self_pos + as_offset
        type: track(format, frame_limit, short_i6_header)
        if: not is_fixed

  track:
    params:
      - id: format
        type: u4
        doc: 1=I4, 2=I6, 3=I12, 4=L1, 5=L2, 6=L4.
      - id: frame_limit
        type: u4
      - id: short_i6_header
        type: bool
    seq:
      - id: body
        type:
          switch-on: format
          cases:
            1: track_i4
            2: track_i6(short_i6_header)
            3: track_i12
            4: track_l1(frame_limit)
            5: track_l2(frame_limit)
            6: track_l4(frame_limit)

  track_i4:
    doc: Indexed, quantized. 16-byte header, 4 bytes/key.
    seq:
      - id: num_keys
        type: u2
      - id: unknown
        type: u2
      - id: frame_scale
        type: f4
      - id: step
        type: f4
      - id: base
        type: f4
      - id: keys
        type: i4_key
        repeat: expr
        repeat-expr: num_keys

  i4_key:
    seq:
      - id: raw
        type: u4
    instances:
      frame_index:
        value: raw >> 24
      step_quant:
        value: raw >> 12 & 0xfff
      tangent_raw:
        value: '(raw & 0xfff) >= 0x800 ? (raw & 0xfff) - 0x1000 : raw & 0xfff'
        doc: Sign-extended 12-bit tangent; divide by 32.0 for the real slope.

  track_i6:
    doc: Indexed, quantized. 16-byte header (8-byte for version < 4), 6 bytes/key.
    params:
      - id: short_header
        type: bool
    seq:
      - id: num_keys
        type: u2
      - id: unknown
        type: u2
      - id: frame_scale
        type: f4
      - id: step
        type: f4
        if: not short_header
      - id: base
        type: f4
        if: not short_header
      - id: keys
        type: i6_key
        repeat: expr
        repeat-expr: num_keys
    instances:
      effective_step:
        value: 'short_header ? 1.0 / 256.0 : step'
      effective_base:
        value: 'short_header ? 0.0 : base'

  i6_key:
    seq:
      - id: index_raw
        type: u2
        doc: Top 11 bits are the frame index (`index_raw >> 5`).
      - id: step_quant
        type: u2
      - id: tangent_raw
        type: s2
        doc: Divide by 256.0 for the real slope.
    instances:
      frame_index:
        value: index_raw >> 5

  track_i12:
    doc: Indexed, raw floats. 8-byte header, 12 bytes/key.
    seq:
      - id: num_keys
        type: u2
      - id: unknown
        type: u2
      - id: frame_scale
        type: f4
      - id: keys
        type: i12_key
        repeat: expr
        repeat-expr: num_keys

  i12_key:
    seq:
      - id: frame
        type: f4
      - id: value
        type: f4
      - id: tangent
        type: f4

  track_l1:
    doc: Dense, quantized. 8-byte header, 1 byte/frame; no explicit tangent.
    params:
      - id: frame_limit
        type: u4
    seq:
      - id: step
        type: f4
      - id: base
        type: f4
      - id: raw
        type: u1
        repeat: expr
        repeat-expr: frame_limit

  track_l2:
    doc: Dense, quantized. 8-byte header, 2 bytes/frame; no explicit tangent.
    params:
      - id: frame_limit
        type: u4
    seq:
      - id: step
        type: f4
      - id: base
        type: f4
      - id: raw
        type: u2
        repeat: expr
        repeat-expr: frame_limit

  track_l4:
    doc: Dense, raw floats. No header, 4 bytes/frame.
    params:
      - id: frame_limit
        type: u4
    seq:
      - id: value
        type: f4
        repeat: expr
        repeat-expr: frame_limit
