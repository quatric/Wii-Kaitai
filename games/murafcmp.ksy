meta:
  id: murafcmp
  title: Muramasa FCMP LZSS container (.abf / .esb / .mbs / .nsb / .nms / .ftx)
  endian: le
doc: |
  "FCMP" LZSS container (see lib-muramasa.c) around MLIB (.abf), EMBP (.esb), NSBD
  (.nsb), NMSB (.nms, see muranms) or FTEX (.ftx, see fcmpftex) bodies.
seq:
  - id: magic
    contents: FCMP
  - id: rest
    size-eos: true
