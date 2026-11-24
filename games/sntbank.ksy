meta:
  id: sntbank
  title: Baroque sound bank table (.snt)
  file-extension: snt
  endian: be
doc: |
  Baroque (Wii) `SOUND_xx/brqsnd.snt`; members live in `brqsnd.snd`. Member i
  spans [end(i-1), end(i)) of the .snd (the first starts at 0). Members are
  mono DSP-ADPCM files; the tail only holds names of external .dsp files.
seq:
  - id: count
    type: u4
  - id: pad
    size: 8
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: type
        type: u4
      - id: volume
        type: u4
        doc: 100.
      - id: kind
        type: u4
      - id: flag
        type: u4
      - id: end_offset
        type: u4
        doc: End offset into the .snd file.
