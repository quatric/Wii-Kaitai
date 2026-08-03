meta:
  id: mobiclip_ds
  file-extension: mods
  endian: le
  doc: |
    Legacy Kaitai for Nintendo DS Mobiclip (.mods).
    Superseded by mobiclip_mods.ksy which has the correct 6-byte magic
    and proper field offsets. This file is kept for compatibility.
    See mobiclip_mods.ksy for the authoritative definition.
seq:
  - id: magic
    contents: [0x4D, 0x4F, 0x44, 0x53, 0x4E, 0x33]
    doc: "'MODSN3' — 6 bytes."
  - id: video_codec
    type: u2
    doc: "0x000A for MobiClip. Offset 0x06."
  - id: frame_count
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: fps
    type: u4
    doc: "Divide by 0x1000000 to get FPS."
  - id: audio_codec
    type: u2
    enum: audio_codec
  - id: nb_channel
    type: u2
  - id: frequency
    type: u4
  - id: biggest_frame
    type: u4
  - id: audio_offset
    type: u4
  - id: keyframe_index_offset
    type: u4
  - id: keyframe_count
    type: u4
  - id: header_done
    contents: [0x48, 0x45]
    doc: "'HE' at offset 0x30."
instances:
  keyframe_table:
    type: keyframe_table
    pos: keyframe_index_offset
    repeat: expr
    repeat-expr: keyframe_count
types:
  keyframe_table:
    seq:
      - id: frame_number
        type: u4
      - id: data_offset
        type: u4
enums:
  audio_codec:
    0: none
    1: sx_codebook
    2: fast_audio
    3: ima_adpcm
    4: pcm16