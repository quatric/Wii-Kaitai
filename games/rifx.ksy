meta:
  id: rifx
  title: Big-endian RIFX WAVE (.wax / .rifx)
  file-extension: wax
  endian: be
doc: 16-bit mono 48 kHz integer PCM in the 2 in 1 / Tierpension style games.
seq:
  - id: magic
    contents: RIFX
  - id: size
    type: u4
  - id: form_type
    contents: WAVE
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
      - id: size
        type: u4
      - id: body
        size: size
      - id: pad
        size: size % 2
