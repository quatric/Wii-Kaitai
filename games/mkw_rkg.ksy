meta:
  id: mkw_rkg
  endian: be
  title: Mario Kart Wii RKG ghost data
doc: |
  Mario Kart Wii RKG ghost-replay file, ported from `rkg_head_t` and
  `ScanRawDataGHOST()` in lib-rkg.h/.c. Reference:
  https://wiki.tockdom.com/wiki/RKG

  Past the fixed 0x88-byte header comes the ghost input data. Bit
  0x0800 of `kind` selects whether it is YAZ-compressed: if so, a
  32-bit compressed size and a 0x10-byte reserved area precede the YAZ
  stream, which inflates to exactly `data_size` bytes; otherwise the
  uncompressed input records follow directly. Either way the
  (possibly decompressed) input data itself starts with three 16-bit
  counts -- button, direction and trick presses -- followed by that
  many 2-byte {input, duration-in-frames} records for each in turn.
seq:
  - id: magic
    contents: "RKGD"
  - id: score_min
    type: b7
  - id: score_sec
    type: b7
  - id: score_milli
    type: b10
  - id: track_id
    type: u1
  - id: id
    type: u4
  - id: kind
    type: u2
  - id: data_size
    type: u2
    doc: Decompressed input-data size.
  - id: any_data
    size: 0x88 - 0x10
  - id: ghost_data
    type: compressed_ghost_t
    if: is_compressed
  - id: input_data
    type: input_data_t
    if: not is_compressed
    size: data_size
instances:
  is_compressed:
    value: (kind & 0x0800) != 0
types:
  compressed_ghost_t:
    doc: >-
      Compressed ghost input data. `compressed_size` covers only the
      YAZ stream that follows the 0x10-byte reserved area; decoding it
      yields an `input_data_t` of `_root.data_size` bytes.
    seq:
      - id: compressed_size
        type: u4
      - id: reserved
        size: 0x10
      - id: yaz_stream
        size: compressed_size
  input_data_t:
    seq:
      - id: num_button_inputs
        type: u2
      - id: num_direction_inputs
        type: u2
      - id: num_trick_inputs
        type: u2
      - id: reserved
        size: 2
      - id: button_inputs
        type: input_entry_t
        repeat: expr
        repeat-expr: num_button_inputs
      - id: direction_inputs
        type: input_entry_t
        repeat: expr
        repeat-expr: num_direction_inputs
      - id: trick_inputs
        type: input_entry_t
        repeat: expr
        repeat-expr: num_trick_inputs
  input_entry_t:
    seq:
      - id: input
        type: u1
        doc: Packed button/direction/trick state; exact bit layout not modeled here.
      - id: duration
        type: u1
        doc: Number of frames this input state is held.
