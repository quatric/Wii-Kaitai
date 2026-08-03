meta:
  id: mobiclip
  file-extension: mo
  endian: le
  doc: |
    Wii Mobiclip video container (.mo / MOC5).
    Used by the Nintendo Channel, Wii no Ma, WiiLink, and in-game FMV.
    See quatric/mobipeg for a full encode+decode implementation.
seq:
  - id: magic
    contents: "MOC5"
  - id: header_size
    type: u4
    doc: |
      Size of the header data after the initial 8 bytes (magic + this field).
      The actual header extends from offset 0x08 to offset header_size + 8.
  - id: tag_sections
    type: tag_section
    repeat: until
    repeat-until: _.tag == "HE"
instances:
  chunk_data:
    pos: header_size + 8
    size-eos: true
    doc: |
      Frame chunks follow immediately after the header.
      Each chunk is: [u32 chunk_size][u32 video_size][video_data][audio_data + padding to 4 bytes].
      Retail files may contain audio-less "skip frame" chunks (all-0xFF P-frames)
      where chunk_size == video_size + 4.
types:
  tag_section:
    doc: |
      Each header section is [u16 tag_LE][u16 word_len_LE] followed by word_len*4
      payload bytes. Known tags: TL (timeline), V2 (video), VC (video codec ID),
      pc (RSA-1280 license signature, 160 bytes), cc (RSA-512 clip certificate, 64 bytes),
      A0/A2/A3/A8/A9/AP/AV/AM (audio), KI (keyframe index),
      LM (MediaLock DRM enable), VF (VerifyFrames), P. (frame-rate num/den),
      HE (header done — must be last).
    seq:
      - id: tag
        type: str
        encoding: ascii
        size: 2
      - id: word_len
        type: u2
      - id: payload
        size: word_len * 4
        if: tag != "HE"
        type:
          switch-on: tag
          cases:
            "'TL'": timeline_payload
            "'V2'": video_payload
            "'A2'": audio_standard_payload
            "'A3'": audio_standard_payload
            "'A8'": audio_standard_payload
            "'A9'": audio_standard_payload
            "'AP'": audio_standard_payload
            "'AM'": audio_multitrack_payload
            "'KI'": keyframe_index_payload
  timeline_payload:
    doc: |
      Timeline info: frame count, FPS, subchunk count.
    seq:
      - id: subchunk_count
        type: u2
      - id: fps
        type: u4
        doc: Frames per second.
      - id: chunk_count
        type: u4
      - id: unknown
        size: _parent.word_len * 4 - 10
        if: _parent.word_len * 4 > 10
  video_payload:
    doc: |
      Video parameters: width, height.
    seq:
      - id: unknown
        type: u2
      - id: width
        type: u4
      - id: height
        type: u4
      - id: rest
        size: _parent.word_len * 4 - 10
        if: _parent.word_len * 4 > 10
  audio_standard_payload:
    doc: |
      Audio stream info. Tag meanings:
        A0 -> None (no audio)
        A2 -> FastAudio mono
        A3 -> FastAudio stereo
        A8 -> IMA ADPCM mono
        A9 -> IMA ADPCM stereo
        AP -> PCM S16
        AV -> Vorbis (unusual framing, see gist §5.3)
    seq:
      - id: stream_type
        type: u2
      - id: frequency
        type: u4
      - id: channel_count
        type: u4
  audio_multitrack_payload:
    doc: |
      Multitrack audio header (tag AM). Contains multiple audio stream definitions.
    seq:
      - id: header_length
        type: u2
      - id: audio_stream_count
        type: u4
      - id: audio_streams
        type: audio_standard_payload
        repeat: expr
        repeat-expr: audio_stream_count
  keyframe_index_payload:
    doc: |
      Keyframe index for seeking. Entry count is in units of 8 bytes
      (each entry is a chunk_offset + frame_index pair).
    seq:
      - id: entry_count
        type: u2
      - id: keyframes
        type: keyframe_entry
        repeat: expr
        repeat-expr: entry_count / 2
      - id: trailer
        size: _parent.word_len * 4 - 2 - (entry_count / 2 * 8)
        if: _parent.word_len * 4 - 2 - (entry_count / 2 * 8) > 0
  keyframe_entry:
    seq:
      - id: chunk_offset
        type: u4
      - id: frame_index
        type: u4
  chunk:
    doc: |
      A single interleaved audio/video frame chunk.
      Retail files may contain "skip frame" chunks where chunk_size == video_size + 4.
      Video data is a MobiClip bitstream (MSB-first over 16-bit LE words).
    seq:
      - id: chunk_size
        type: u4
      - id: video_chunk_size
        type: u4
      - id: video_chunk
        size: video_chunk_size
      - id: audio_chunk
        if: chunk_size - video_chunk_size - 8 > 0
        size: chunk_size - video_chunk_size - 8
