meta:
  id: switch_opus
  title: Nintendo Switch Opus (.opus / .lopus / .opusnx)
  file-extension: lopus
  endian: le
doc: |
  Header chunks 0x80000001 info, 0x80000003 context, 0x80000004 data,
  0x80000005 multistream (after vgmstream opus.c). Packets in the data chunk
  are each prefixed by a big-endian u32 size and a u32 final range value. The
  NUS3AUDIO variant wraps this in a big-endian "OPUS" header.
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
    instances:
      is_data:
        value: tag == 0x80000004
  packet:
    seq:
      - id: size
        type: u4be
      - id: final_range
        type: u4be
      - id: data
        size: size
