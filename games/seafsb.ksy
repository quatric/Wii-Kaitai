meta:
  id: seafsb
  title: Bully Scholarship Edition .SEA sound bank
  file-extension: sea
  endian: be
doc: '{u32 BE offset of the embedded FMOD bank, sound descriptions with CDCD-padded names ...} and an FSB3/FSB4 bank at that offset to EOF.'
seq:
  - id: fsb_offset
    type: u4
  - id: descriptions
    size: fsb_offset - 4
  - id: fsb
    size-eos: true
