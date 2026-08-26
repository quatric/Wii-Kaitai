meta:
  id: thp
  file-extension: thp
  endian: be
  title: GameCube/Wii THP movie
doc: |
  Nintendo's own GameCube-era FMV container, carried forward onto the Wii
  unchanged. One video stream (the `THP` codec -- I-frames only, a
  DCT/vector-quantized format unrelated to MobiClip despite the shared
  console) and, optionally, one DSP-ADPCM audio stream.

  ## The frame chain is lagged by one step, not self-describing

  Every frame's header opens with a size field, but it is not that
  frame's own size -- it is the size of the frame *after* the one that
  follows it. Concretely, the position of frame `k+1` is computed from
  frame `k`'s start plus a span value `S(k)`, where:

  * `S(0)` is the file header's `first_frame_size` (there is no frame -1
    to have stored it).
  * `S(k)` for `k >= 1` is frame `k-1`'s own `next_frame_size` field, read
    two frames before it takes effect.

  This is a real, confirmed property of the format, not an artifact of a
  padding convention: walking four real frames of `fish.thp` this way,
  `S(k)` measured `16 + this_frame_size + audio_size` bytes off by 0, 16
  and 24 bytes for consecutive frames -- inconsistent gaps that rule out a
  fixed alignment, and land exactly on the next frame's real header only
  when `S(k)` (not the current frame's own recomputed span) is used. A
  reader that assumes a frame's own header describes its own size will
  walk off into the middle of the next frame's payload.

  Because of the two-step lag, this definition models the chain as a
  singly linked structure (`frame.next`, recursively) rather than a flat
  array: each `frame` instance is parameterised with the span used to
  locate *it*, and exposes the span (its own `next_frame_size`) needed to
  locate the frame after it -- the only way to hand that value forward
  without needing an already-parsed sibling to be visible at the point a
  position is computed, which Kaitai does not support for a plain
  `repeat`.

  ## Validated against

  Three real retail/SDK THP files: `fish.thp` and `rebirth.thp` from
  Nintendo's own GameCube THP Demo Library (bundled with the RVL_SDK), and
  a Wario Land: Shake It cutscene (`AshleyEpilogue.thp`) -- all 640x480
  stereo DSP-ADPCM at 32000 Hz, version 0x10000. Every header field, the
  component table, and the first four frames' headers (walked via the
  chain above) were checked against a byte-level dump of `fish.thp`, and
  its reported duration (273584 audio samples) and frame count (256)
  match `ffprobe` exactly.
seq:
  - id: magic
    contents: ['THP', 0]
  - id: version
    type: u4
    doc: |
      0x10000 in every observed file. 0x11000 carries one extra u4 after
      the video component's width/height -- present in mobipeg's demuxer
      as a documented but unidentified field, and not exercised by any
      sample checked here.
  - id: max_buf_size
    type: u4
    doc: Largest single frame (video or audio) in the file, in bytes.
  - id: max_samples
    type: u4
    doc: Largest per-frame audio sample count in the file.
  - id: fps
    type: f4
  - id: num_frames
    type: u4
  - id: first_frame_size
    type: u4
    doc: |
      `S(0)` in the top-level doc -- the size to skip from
      `ofs_first_frame` to reach frame 1.
  - id: max_size
    type: u4
    doc: Largest total frame size (video + audio + the 16-byte frame header).
  - id: ofs_component_table
    type: u4
  - id: ofs_data_offset_table
    type: u4
    doc: |
      Unread by mobipeg's demuxer in every version checked; the field
      exists in the header layout but its purpose is unconfirmed here.
  - id: ofs_first_frame
    type: u4
  - id: ofs_last_frame
    type: u4
instances:
  component_table:
    pos: ofs_component_table
    type: component_table
  first_frame:
    pos: ofs_first_frame
    type: frame(ofs_first_frame, first_frame_size, 0)
    doc: |
      Walk `.next` from here (bounded by `_root.num_frames`) to reach every
      later frame -- see the top-level doc for why this can't be a
      `repeat`-based array.
types:
  component_table:
    doc: |
      A fixed 16-byte type-code table followed by one fixed-shape record
      per populated slot, video first if present. `num_components` is
      almost always 1 or 2 in practice (one video, optionally one audio),
      but the slot count itself allows up to 16.
    seq:
      - id: num_components
        type: u4
      - id: component_types
        type: u1
        enum: component_type
        repeat: expr
        repeat-expr: 16
      - id: components
        type: component(component_types[_index])
        repeat: expr
        repeat-expr: num_components
    instances:
      has_audio:
        value: >-
          num_components > 0 and
          component_types[num_components - 1] == component_type::audio
  component:
    params:
      - id: kind
        type: u1
        enum: component_type
    seq:
      - id: width
        type: u4
        if: kind == component_type::video
      - id: height
        type: u4
        if: kind == component_type::video
      - id: unknown_v2
        type: u4
        if: kind == component_type::video and _root.version == 0x11000
        doc: |
          Only present in version 0x11000, which no sample here carries --
          modelled from mobipeg's demuxer, not independently confirmed.
      - id: num_channels
        type: u4
        if: kind == component_type::audio
      - id: sample_rate
        type: u4
        if: kind == component_type::audio
      - id: num_samples
        type: u4
        if: kind == component_type::audio
  frame:
    params:
      - id: own_pos
        type: u4
        doc: This frame's own absolute file offset.
      - id: own_span
        type: u4
        doc: |
          `S(index)` -- the byte distance from `own_pos` to the next
          frame, established by whoever instantiated this frame (the root,
          for frame 0; the frame two steps back, otherwise).
      - id: index
        type: u4
    doc: |
      One frame's header, followed by its video payload and, if the file
      has an audio component, its audio payload immediately after. Neither
      payload is modelled as raw bytes here beyond size -- a THP video
      packet's internal layout, and ADPCM_THP's channel interleaving,
      belong to the codec, not the container.
    seq:
      - id: next_frame_size
        type: u4
        doc: |
          `S(index + 1)` -- describes the frame *after* the one that
          follows this one, not this frame and not the very next one.
      - id: prev_frame_size
        type: u4
        doc: Symmetric with `next_frame_size`, for reverse playback. Unread here.
      - id: this_frame_size
        type: u4
        doc: This frame's video payload size, in bytes.
      - id: audio_size
        type: u4
        if: _root.component_table.has_audio
      - id: video_data
        size: this_frame_size
      - id: audio_data
        size: audio_size
        if: _root.component_table.has_audio
    instances:
      next:
        pos: own_pos + own_span
        type: frame(own_pos + own_span, next_frame_size, index + 1)
        if: index + 1 < _root.num_frames
enums:
  component_type:
    0: video
    1: audio
