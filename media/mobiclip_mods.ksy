meta:
  id: mobiclip_mods
  file-extension: mods
  endian: le
  doc: |
    Nintendo DS Mobiclip video container (.mods / MODSN3).
    Uses YCgCo colorspace (NOT YCbCr). Feeding YCbCr produces the classic
    "everything is green" bug.
    Audio is embedded as trailing bytes inside each video chunk — there are
    no separate audio chunks.
    All chunk payloads and frame offsets must be 4-byte aligned for DS hardware.
seq:
  - id: magic
    contents: [0x4D, 0x4F, 0x44, 0x53, 0x4E, 0x33]
    doc: "'MODSN3' — 6 bytes."
  - id: video_codec
    type: u2
    doc: "0x000A for MobiClip. Bytes 0x06-0x07."
  - id: nb_frames
    type: u4
    doc: "Offset 0x08."
  - id: width
    type: u4
    doc: "Offset 0x0C. Typically 256 for DS."
  - id: height
    type: u4
    doc: "Offset 0x10. Typically 192 for DS."
  - id: fps
    type: u4
    doc: "Offset 0x14. Divide by 0x1000000 to get actual FPS."
  - id: audio_codec
    type: u2
    enum: audio_codec
    doc: "Offset 0x18."
  - id: channels
    type: u2
    doc: "Offset 0x1A."
  - id: sample_rate
    type: u4
    doc: "Offset 0x1C."
  - id: largest_frame_index
    type: u4
    doc: "Offset 0x20."
  - id: audio_codec_info_offset
    type: u4
    doc: |
      Offset 0x24. Points to end of interleaved frame data.
      For SX/codebook audio (codec 1), this is where the 3124-byte
      per-channel codebook lives.
  - id: keyframe_table_offset
    type: u4
    doc: "Offset 0x28."
  - id: keyframe_count
    type: u4
    doc: "Offset 0x2C."
  - id: header_done
    contents: [0x48, 0x45]
    doc: "'HE' marker at offset 0x30."
instances:
  keyframe_table:
    pos: keyframe_table_offset
    type: keyframe_entry
    repeat: expr
    repeat-expr: keyframe_count
enums:
  audio_codec:
    0: none
    1: sx_codebook
    2: fast_audio
    3: ima_adpcm
    4: pcm16
types:
  keyframe_entry:
    seq:
      - id: frame_number
        type: u4
      - id: data_offset
        type: u4
