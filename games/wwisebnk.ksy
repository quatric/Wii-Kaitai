meta:
  id: wwisebnk
  title: Audiokinetic Wwise sound bank (Wii, big endian)
  file-extension: bnk
  endian: be
doc: |
  Epic Mickey. Wii members are big-endian RIFX/WAVE with a 'WiiH' chunk
  (16 x s16 DSP coefficients, gain / initial ps).
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
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: tag
          cases:
            '"DIDX"': didx
    doc: BKHD header, DIDX media index, DATA embedded media.
  didx:
    seq:
      - id: entries
        type: entry
        repeat: eos
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
        doc: Relative to the DATA chunk body.
      - id: size
        type: u4
