meta:
  id: eaaems
  title: EA Sports AEMS stream (FaceBreaker K.O. Party)
  file-extension: aems
  endian: be
doc: |
  Header "S10S", packets from 0x40. Packet {u32 flags | size, u32 samples per
  channel, payload}; flag 0x80 packets are stream control and skipped. Payload
  is EA-XAS v1: 0x4c-byte blocks of 128 samples with four 4-byte LE group
  headers followed by 15 rows of 4 data bytes. Rate not stored (32000 assumed).
seq:
  - id: magic
    contents: S10S
  - id: header
    size: 0x40 - 4
  - id: packets
    type: packet
    repeat: eos
types:
  packet:
    seq:
      - id: flags_size
        type: u4
        doc: Top byte flags, low 24 bits size covering the packet.
      - id: samples_per_channel
        type: u4
      - id: payload
        size: (flags_size & 0xffffff) - 8
