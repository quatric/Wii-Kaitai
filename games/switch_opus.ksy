meta:
  id: switch_opus
  title: Nintendo Switch Opus (.opus / .lopus / .opusnx)
  file-extension: lopus
  endian: le
doc: |
  Header chunks 0x80000001 info, 0x80000003 context, 0x80000004 data,
  0x80000005 multistream (after vgmstream opus.c). The data chunk holds
  packets each prefixed by a big-endian u32 size and a u32 final range value.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: u4
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: tag
          cases:
            0x80000004: packets
  packets:
    seq:
      - id: packets
        type: packet
        repeat: eos
  packet:
    seq:
      - id: size
        type: u4be
      - id: final_range
        type: u4be
      - id: data
        size: size
