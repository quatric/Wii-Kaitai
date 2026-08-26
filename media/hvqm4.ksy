meta:
  id: hvqm4
  file-extension: h4m
  endian: be
  title: Hudson Soft HVQM4 movie
doc: |
  Hudson Soft's GameCube/Wii FMV codec, used across many first- and
  second-party titles (Mario Kart Wii's menu and ending movies among
  them). One video stream (`hvqm4`, a from-scratch decoder in mobipeg --
  see its README for what the encoder does and does not implement yet)
  and, unlike THP (`media/thp.ksy`), the audio interleaving is simpler:
  frames are grouped into GOPs, and every frame record inside a GOP --
  audio or video -- is read purely sequentially, each one's own size
  field giving exactly how far to advance to the next. There is no THP-style
  lag where a size field describes something other than the record it is
  attached to.

  `header_size` (checked against the fixed value `0x44` by mobipeg's
  demuxer) doubles as the absolute file offset where GOP 0 begins --
  there is no separate "first GOP offset" field, because the header is
  always this one fixed size.

  A GOP's own `prev_size`/`next_size` pair exists for backward and forward
  seeking; forward sequential playback (and this definition's normal
  parse) never needs them; a GOP's frames are consumed purely by counting
  `nb_video_frames + nb_audio_frames` records.

  Each frame record is `media_type(u2), frame_type(u2), frame_size(u4),
  disp_id(u4), payload`, where `frame_size` measures `disp_id` plus the
  payload together (not the record's own two leading `u2` fields) -- so a
  record's total footprint on disk is `8 + frame_size`. `disp_id` is a
  display-order index (used by the demuxer to compute presentation
  timestamps relative to the GOP's first frame), not a byte count.

  ## Validated against

  Two real Mario Kart Wii (P-GKYE) movies pulled from the game's own
  `files/` tree: `MvOpening.h4m` (640x480, 89 GOPs, 2660 video + 2660
  audio frames, 32028 Hz stereo 16-bit audio) and `MvHowtoPlay.h4m`
  (568x424). GOP 0's header and its first ten frame records -- four video
  (one key frame followed by three inter frames, `disp_id` running
  0,1,2,3) and six audio, alternating as the container interleaves them --
  were walked and checked against a byte-level dump of `MvOpening.h4m`;
  every video frame after the first landed on a `frame_type` of `0x20`
  (inter) following the first's `0x10` (key), and audio records carried
  `0x1` for the GOP's first frame and `0x2` after -- a pattern observed,
  not independently confirmed against Hudson's own encoder.
seq:
  - id: magic
    size: 16
    doc: '`HVQM4 1.3\0\0\0\0\0\0\0` or `HVQM4 1.5\0\0\0\0\0\0\0`, exactly 16 bytes.'
  - id: len_header
    type: u4
    doc: |
      0x44 in every observed file -- both the fixed header's own length
      and, doubling as that, the absolute file offset where GOP 0 begins.
  - id: len_body
    type: u4
  - id: num_gops
    type: u4
  - id: num_video_frames
    type: u4
    doc: Total across the whole file, not per GOP.
  - id: num_audio_frames
    type: u4
  - id: frame_usec
    type: u4
    doc: |
      Microseconds per video frame. 0 falls back to 33367 (~29.97 fps) in
      mobipeg's demuxer; every sample checked here carries a real value
      instead (16683, ~59.94 fps, in both Mario Kart Wii files -- a movie
      encoded at double the frame rate `frame_usec`'s fallback assumes).
  - id: max_frame_size
    type: u4
  - id: reserved
    type: u4
  - id: audio_frame_size
    type: u4
    doc: Bytes per audio frame's payload, uniform across the file.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: chroma_hsamp
    type: u1
    doc: Horizontal chroma subsampling factor. 2 (4:2:0) in every sample checked.
  - id: chroma_vsamp
    type: u1
  - id: video_mode
    type: u1
  - id: reserved2
    type: u1
  - id: audio_channels
    type: u1
  - id: audio_bit_depth
    type: u1
  - id: reserved3
    type: u2
  - id: audio_sample_rate
    type: u4
instances:
  gops:
    pos: len_header
    type: gop
    repeat: expr
    repeat-expr: num_gops
    doc: |
      Contiguous and sequential -- unlike `media/thp.ksy`'s frame chain,
      no jump arithmetic is needed between GOPs; each one's own frame
      count says exactly how many records to read before the next GOP
      header begins.
types:
  gop:
    seq:
      - id: len_prev_gop
        type: u4
        doc: Byte size of the previous GOP, 0 for GOP 0. Unread by mobipeg's demuxer.
      - id: len_next_gop
        type: u4
        doc: |
          Byte size of this GOP, for backward/forward seeking. Unread
          during ordinary sequential parsing, including this definition's.
      - id: num_video_frames
        type: u4
      - id: num_audio_frames
        type: u4
      - id: marker
        type: u4
        doc: |
          0x01000000 in every observed GOP; mobipeg's demuxer logs a
          warning (but does not reject the file) when this differs.
      - id: frames
        type: frame_record
        repeat: expr
        repeat-expr: num_video_frames + num_audio_frames
        doc: |
          Interleaved audio and video records in encounter order, told
          apart by each record's own `media_type` -- not grouped by kind.
  frame_record:
    seq:
      - id: media_type
        type: u2
        enum: media_type
      - id: frame_type
        type: u2
        doc: |
          For video: 0x10 marks a key (intra) frame, 0x20 an inter frame.
          For audio: 0x1 on the GOP's first audio frame and 0x2 on every
          one after it, in both files checked -- a real, observed pattern,
          not confirmed against any other encoder or a spec.
      - id: len_frame
        type: u4
        doc: |
          Counts `disp_id` plus `payload` together -- 4 bytes more than
          `payload`'s own size. This record's total footprint on disk is
          `8 + len_frame` (this field's own 8-byte prefix, plus the value
          it holds).
      - id: disp_id
        type: u4
        doc: |
          Display-order index within the file (video) or GOP (audio), used
          to derive a presentation timestamp relative to the GOP's first
          video frame -- not a byte offset or count.
      - id: payload
        size: len_frame - 4
enums:
  media_type:
    0: audio
    1: video
