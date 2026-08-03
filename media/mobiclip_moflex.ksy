meta:
  id: mobiclip_moflex
  file-extension: moflex
  endian: be
  doc: |
    3DS/DSi Mobiclip live-streaming container (.moflex).
    Used by 3DS eShop trailers, BOSS video, Nintendo Video.
    Blocks are exactly 4096 bytes — the 3DS firmware uses a fixed 4096-byte
    read buffer and 2048-byte blocks crash real hardware.
    A sync header repeats the full descriptor list roughly once per second.
    A video frame must never span a sync-counter change.
    3DS stereoscopic 3D is a single video stream with a layout byte in
    type-3 descriptors (not two separate streams).
seq:
  - id: magic
    contents: [0x4C, 0x32]
    doc: "Big-endian 0x4C32."
  - id: unknown
    size: 2
  - id: timestamp_us
    type: u8
    doc: "Timestamp in microseconds."
  - id: block_size_minus_1
    type: u2
    doc: "Block size - 1. Should be 4095 (= 4096-byte blocks)."
  - id: descriptors
    type: descriptor
    repeat: until
    repeat-until: _.type == 0
  - id: flags
    type: u1
    doc: |
      (counter << 2) | variable_packet_size_bit.
      The 6-bit counter increments only on sync blocks.
  - id: packets
    size-eos: true
    doc: |
      Bit-packed packets: stream_index (pop_length + pop_int),
      endframe bit, pkt_size = pop_int(13) + 1.
types:
  descriptor:
    doc: |
      Stream descriptors.
        type 0: end of list
        type 1: video (12 bytes: idx, codec, fps den16, num16, w16, h16, ...)
        type 2: audio (6 bytes)
        type 3: video-with-layout (13 bytes = type 1 + 1 layout byte for 3D)
        type 4: data (2 bytes, used for seek table at stream index 2)
    seq:
      - id: type
        type: u1
      - id: size
        type: u1
        if: type != 0
      - id: payload
        size: size
        if: type != 0
        type:
          switch-on: type
          cases:
            1: video_descriptor
            3: video_layout_descriptor
  video_descriptor:
    doc: "Video stream descriptor (type 1), 12 bytes."
    seq:
      - id: stream_index
        type: u1
      - id: codec_id
        type: u1
      - id: fps_denominator
        type: u2
      - id: fps_numerator
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: unknown
        size: _parent.size - 10
        if: _parent.size > 10
  video_layout_descriptor:
    doc: |
      Video-with-layout descriptor (type 3), 13 bytes.
      Layout byte: (ImageLayout & 0xF) | (ImageRotation << 4).
      ImageLayout values:
        0 = Interleave3D-LeftFirst, 1 = Interleave3D-RightFirst,
        2 = TopToBottom-LeftFirst, 3 = TopToBottom-RightFirst,
        4 = SideBySide-LeftFirst, 5 = SideBySide-RightFirst,
        6 = Simple2D
    seq:
      - id: stream_index
        type: u1
      - id: codec_id
        type: u1
      - id: fps_denominator
        type: u2
      - id: fps_numerator
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: layout
        type: u1
        doc: "(ImageLayout & 0xF) | (ImageRotation << 4)"
      - id: unknown
        size: _parent.size - 11
        if: _parent.size > 11

enums:
  image_layout:
    0: interleave3d_left_first
    1: interleave3d_right_first
    2: top_to_bottom_left_first
    3: top_to_bottom_right_first
    4: side_by_side_left_first
    5: side_by_side_right_first
    6: simple_2d
