meta:
  id: eamus
  title: EA PathFinder .mus stream bank
  file-extension: mus
  endian: le
doc: |
  Zero-filled header (non-zero checksum word at 0) followed by many "SCHl"
  ... "SCEl" EA streams back to back at natural 0x100-aligned positions; the
  sibling .mpf holds the interactive playback graph.
seq:
  - id: checksum
    type: u4
  - id: body
    size-eos: true
