meta:
  id: ealayer3
  title: EA SCHl stream carrying EALayer3 audio
  endian: le
doc: |
  Same SCHl block container as eaxa (codec2 0x17). EA frames hold one granule each
  (header byte 0 = 0x00 or 0xee for a raw PCM block) with a compact MPEG header +
  side info; two granules re-assemble into a standard MPEG-1 Layer III frame (one
  for MPEG-2/2.5). The audio data of a "SCDl" block starts at +0x0c + channels * 4
  + first offset.
seq:
  - id: magic
    contents: SCHl
  - id: header_size
    type: u4
  - id: header
    size: header_size - 8
  - id: blocks
    size-eos: true
