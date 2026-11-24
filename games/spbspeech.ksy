meta:
  id: spbspeech
  title: Disney Think Fast speech pack (.SPB)
  file-extension: spb
  endian: be
doc: |
  A run of complete DSP-ADPCM files (0x60-byte BE DSP header + frames, start
  address 2, current 2, end = nibbles - 1), each starting on a 0x8000 boundary,
  no index.
seq:
  - id: files
    type: file
    repeat: eos
types:
  file:
    seq:
      - id: sample_count
        type: u4
      - id: nibble_count
        type: u4
      - id: rate
        type: u4
      - id: header_rest
        size: 0x60 - 12
      - id: frames
        size: (nibble_count + 15) / 16 * 8
      - id: pad
        size: (-(0x60 + (nibble_count + 15) / 16 * 8)) % 0x8000
