meta:
  id: adx
  title: CRI ADX audio (.adx)
  file-extension: adx
  endian: be
doc: |
  CRI ADX audio (Ghost Squad, Arc Rise Fantasia, ...). Sample data starts at
  `copyright_offset + 4`. Type 3 is standard; the exponential type 4 is not
  handled by nintoolbox. A frame of `frame_size` bytes holds a 13-bit
  predictor/scale word and 4-bit samples.
seq:
  - id: signature
    contents: [0x80, 0x00]
  - id: copyright_offset
    type: u2
  - id: encoding_type
    type: u1
    doc: 3 = standard, 4 = exponential.
  - id: frame_size
    type: u1
    doc: 18.
  - id: bit_depth
    type: u1
    doc: 4.
  - id: num_channels
    type: u1
  - id: sample_rate
    type: u4
  - id: num_samples
    type: u4
  - id: highpass_frequency
    type: u2
