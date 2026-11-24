meta:
  id: ogl
  title: Shin'en .ogl (Jett Rocket)
  file-extension: ogl
  endian: le
doc: |
  Vorbis packets each prefixed with a u16 LE (size << 2 | flags): the
  identification ("\x01vorb"), comment and setup packets, then audio packets.
  Re-wrapped unchanged into Ogg Vorbis.
seq:
  - id: loop_offset
    type: u4
  - id: loop_start_sample
    type: u4
  - id: loop_block
    type: u4
  - id: sample_count
    type: u4
  - id: size_without_padding
    type: u4
  - id: packets
    type: packet
    repeat: eos
types:
  packet:
    seq:
      - id: size_flags
        type: u2
      - id: data
        size: size_flags >> 2
