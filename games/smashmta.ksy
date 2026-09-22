meta:
  id: smashmta
  endian: be
  title: Super Smash Bros. 4 material animation (MTA4)
doc: |
  Super Smash Bros. 4 material animation (.mta), per
  lib-smashmta.c (ported from KillzXGaming/Smash-Forge MTA.cs).
  The source requires at least 44 file bytes, though the fields it reads
  from the header occupy offsets 0..39. Material and visibility tables
  contain absolute file offsets, as do their nested name, property,
  keyframe, and value pointers. They are not relative to their parent
  record. MTA4 can animate numeric material properties, switch texture
  IDs through PAT0 keys, and toggle visibility through VIS0 keys.

  The decoder validates the top-level table counts (at most 100000 each),
  NUL-terminated names, and nested table bounds before emitting text.
  One inconsistency in lib-smashmta.c matters for unusual files: its
  property validator reads a 32-bit data offset starting at property
  byte 18, overlapping the animation-type halfword, whereas its decoder
  reads the field at byte 20. Likewise its visibility validator reads
  key count/offset two bytes later than its decoder. The structures here
  follow the decoder's field reads; they do not reproduce those validator
  mistakes or guarantee every synthetic file will pass IsMTA().
seq:
  - id: magic
    contents: "MTA4"
  - id: unknown_04
    type: u4
    doc: Header word retained in text output with unknown meaning.
  - id: frame_count
    type: u4
    doc: Animation frame count.
  - id: start_frame
    type: u4
    doc: First frame number in the animation range.
  - id: end_frame
    type: u4
    doc: Last frame number in the animation range.
  - id: frame_rate
    type: u4
    doc: Frame-rate value reported by the decoder.
  - id: mat_count
    type: u4
    doc: Number of absolute material-record offsets.
  - id: mat_table_offset
    type: u4
    doc: Absolute offset of the material-offset table.
  - id: vis_count
    type: u4
    doc: Number of absolute visibility-record offsets.
  - id: vis_table_offset
    type: u4
    doc: Absolute offset of the visibility-offset table.
instances:
  materials:
    type: material_ref
    repeat: expr
    repeat-expr: mat_count
    pos: mat_table_offset
    doc: Offset references to material records.
  visibilities:
    type: visibility_ref
    repeat: expr
    repeat-expr: vis_count
    pos: vis_table_offset
    doc: Offset references to VIS0 records.
types:
  material_ref:
    seq:
      - id: offset
        type: u4
        doc: Absolute material-record offset.
    instances:
      material:
        io: _root._io
        pos: offset
        type: material_record
  material_record:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute NUL-terminated material-name offset.
      - id: name_hash
        type: s4
        doc: Stored hash of the primary material name.
      - id: property_count
        type: u4
        doc: Number of property-offset references.
      - id: property_table_offset
        type: u4
        doc: Absolute offset of the property-offset table.
      - id: has_pattern
        type: u1
        doc: Nonzero when the PAT0 texture-pattern pointer is used.
      - id: reserved_11
        size: 3
        doc: Three bytes not interpreted by the decoder.
      - id: pattern_offset
        type: u4
        doc: Absolute offset of the PAT0 pointer word.
      - id: second_name_offset
        type: u4
        doc: Optional second material name; zero means absent.
      - id: second_name_hash
        type: s4
        doc: Stored hash associated with the optional second material.
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: str
        encoding: UTF-8
        terminator: 0
      second_name:
        io: _root._io
        pos: second_name_offset
        type: str
        encoding: UTF-8
        terminator: 0
        if: second_name_offset != 0
      properties:
        io: _root._io
        pos: property_table_offset
        type: property_ref
        repeat: expr
        repeat-expr: property_count
      pattern:
        io: _root._io
        pos: pattern_offset
        type: pattern_ref
        if: has_pattern != 0
  property_ref:
    seq:
      - id: offset
        type: u4
    instances:
      property:
        io: _root._io
        pos: offset
        type: property_record
  property_record:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute NUL-terminated property-name offset.
      - id: unknown_04
        type: s4
        doc: Property control word printed by the decoder but not interpreted.
      - id: values_per_frame
        type: u4
        doc: Number of float components in each animation frame.
      - id: frame_count
        type: u4
        doc: Number of float-vector frames stored at data_offset.
      - id: unknown_10
        type: u2
        doc: Second property control value printed by the decoder.
      - id: animation_type
        type: u2
        doc: Animation-type selector carried in the property record.
      - id: data_offset
        type: u4
        doc: Absolute offset read by the decoder at property byte 20.
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: str
        encoding: UTF-8
        terminator: 0
      values:
        io: _root._io
        pos: data_offset
        type: f4
        repeat: expr
        repeat-expr: values_per_frame * frame_count
        doc: Row-major float values, frame by frame.
  pattern_ref:
    seq:
      - id: data_offset
        type: u4
        doc: Zero denotes an empty PAT0 block.
    instances:
      data:
        io: _root._io
        pos: data_offset
        type: pattern_data
        if: data_offset != 0
  pattern_data:
    seq:
      - id: default_texture_id
        type: s4
        doc: Texture ID used before or without a pattern key.
      - id: key_count
        type: u4
        doc: Number of eight-byte texture-switch keys.
      - id: key_offset
        type: u4
        doc: Absolute offset of the pattern-key array.
      - id: frame_count
        type: s4
        doc: Frame count stored by PAT0, distinct from the file header value.
      - id: unknown_10
        type: s4
        doc: PAT0 control word with unknown meaning.
    instances:
      keys:
        io: _root._io
        pos: key_offset
        type: pattern_key
        repeat: expr
        repeat-expr: key_count
  pattern_key:
    seq:
      - id: texture_id
        type: u4
        doc: Texture selected by this key.
      - id: frame_number
        type: s4
        doc: Frame at which this texture key applies.
  visibility_ref:
    seq:
      - id: offset
        type: u4
    instances:
      visibility:
        io: _root._io
        pos: offset
        type: visibility_record
  visibility_record:
    seq:
      - id: name_offset
        type: u4
        doc: Absolute NUL-terminated visibility-channel name offset.
      - id: unknown_04
        type: u4
        doc: Visibility record word ignored by the decoder.
      - id: data_offset
        type: u4
        doc: Absolute offset of the VIS0 keyframe header.
    instances:
      name:
        io: _root._io
        pos: name_offset
        type: str
        encoding: UTF-8
        terminator: 0
      data:
        io: _root._io
        pos: data_offset
        type: visibility_data
  visibility_data:
    seq:
      - id: frame_count
        type: s4
        doc: VIS0 animation frame count.
      - id: is_constant
        type: u2
        doc: Nonzero denotes a constant visibility channel in text output.
      - id: key_count
        type: u2
        doc: Number of four-byte visibility keys.
      - id: key_offset
        type: u4
        doc: Absolute offset of the visibility-key array.
    instances:
      keys:
        io: _root._io
        pos: key_offset
        type: visibility_key
        repeat: expr
        repeat-expr: key_count
  visibility_key:
    seq:
      - id: frame_number
        type: s2
        doc: Frame number at which the visibility state changes.
      - id: state
        type: u1
        doc: Visibility state at this keyframe.
      - id: unknown
        type: u1
        doc: Per-key byte emitted in text output without further interpretation.
