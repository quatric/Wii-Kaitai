meta:
  id: usm
  title: CRI USM movie (Sofdec 2)
  file-extension: usm
  endian: be
doc: |
  Payload = bytes [8 + payload_offset, 8 + size - padding). Data chunks of each
  stream are joined: @SFV video -> MPEG-1, @SFA audio -> ADX.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
        doc: CRID, @SFV, @SFA, @ALP.
      - id: size
        type: u4
      - id: zero
        type: u1
      - id: payload_offset
        type: u1
      - id: padding
        type: u2
      - id: channel
        type: u1
      - id: reserved0
        size: 2
      - id: type
        type: u1
        doc: 0 data, 1 header (@UTF table), 2 end, 3 seek.
      - id: frame_time
        type: u4
      - id: frame_rate
        type: u4
      - id: reserved1
        size: 8
      - id: body
        size: size - 0x18
