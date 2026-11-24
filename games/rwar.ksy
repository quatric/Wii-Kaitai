meta:
  id: rwar
  title: NW4R wave archive (.brwar / .rwar) and single waves (.rwav)
  file-extension: rwar
  endian: be
doc: Waves are DSP-ADPCM, PCM16 or PCM8, mono or stereo; names live in the matching RWSD.
seq:
  - id: magic
    size: 4
    doc: '"RWAR" or "RWAV".'
  - id: bom
    type: u2
  - id: version
    type: u2
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: block_count
    type: u2
  - id: rest
    size-eos: true
