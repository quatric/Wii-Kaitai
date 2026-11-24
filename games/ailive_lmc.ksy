meta:
  id: ailive_lmc
  title: AiLive LiveMove classifier database (.lmc)
  file-extension: lmc
  endian: le
doc: |
  Top Spin 3/4, Don King Boxing. u32 file size, then a serialised object stream:
  tagged records whose type and member names are u16-length-prefixed ASCII
  strings ("readableHeader:", "gaussianXMotionClassifierPair", "nameMap", gesture
  names, "matrixDynamic<float>") interleaved with float matrices (the trained
  models).
seq:
  - id: file_size
    type: u4
  - id: stream
    size-eos: true
types:
  lp_string:
    seq:
      - id: length
        type: u2
      - id: text
        size: length
        type: str
        encoding: ASCII
