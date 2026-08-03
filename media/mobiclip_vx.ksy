meta:
  id: mobiclip_vx
  file-extension: vx
  endian: le
  doc: |
    Nintendo DS Actimagine VX video container (.vx / VXDS).
    Uses a completely different, older codec than MobiClip.
    Colorspace is neither YCbCr nor YCgCo — a shift-based YCoCg-ish approximation.
    Standard H.264 CAVLC residuals. 24 macroblock modes.
    One global quantizer for the whole file (valid range 12-161).
    Hardware alignment: (frame_data_size + 2) % 4 == 0 required,
    otherwise audio desynchronizes (perfect video, white-noise static).
seq:
  - id: magic
    contents: "VXDS"
  - id: frames_qty
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: frame_rate
    type: u4
    doc: "16.16 fixed-point: divide by 0x10000 to get actual FPS."
  - id: quantizer
    type: u4
    doc: "Global quantizer for the whole file. Valid range 12-161. Past ~160 all coefficients round to zero."
  - id: audio_sample_rate
    type: u4
  - id: audio_streams_qty
    type: u4
  - id: frame_data_size_max
    type: u4
  - id: audio_extradata_offset
    type: u4
  - id: seek_table_offset
    type: u4
  - id: seek_table_entries
    type: u4
  - id: frames
    type: frame_record
    repeat: expr
    repeat-expr: frames_qty
instances:
  audio_extradata:
    pos: audio_extradata_offset
    size: 3124 * audio_streams_qty
    if: audio_streams_qty > 0
    doc: |
      3124 bytes PER CHANNEL. Layout per channel:
        [3072 B = 3x64x8 int16 LPC codebooks]
        [16 B = 8x u16 scale modifiers]
        [32 B = 8x i32 lpc_base]
        [4 B u32 scale_initial]
  seek_table:
    pos: seek_table_offset
    type: seek_entry
    repeat: expr
    repeat-expr: seek_table_entries
types:
  frame_record:
    doc: |
      Per-frame record: [u16 frame_data_size][u16 aframes_qty][payload].
      The payload is one video frame's bitstream immediately followed by
      N 128-sample audio frames in the same bitstream.
      Video ends word-aligned exactly where audio begins.
    seq:
      - id: frame_data_size
        type: u2
      - id: aframes_qty
        type: u2
        doc: "Number of 128-sample audio periods in this frame."
      - id: payload
        size: frame_data_size
  seek_entry:
    seq:
      - id: frame_id
        type: u4
      - id: offset
        type: u4
