meta:
  id: ai00
  title: One Piece Unlimited Adventure/Cruise ai00 / aicd tables
  file-extension: bin
  endian: be
doc: '{"ai00", u32 version (3), u32 ...} followed by u32 words (ints or floats). Field names and record layout are not known.'
seq:
  - id: magic
    size: 4
    doc: '"ai00" or "aicd".'
  - id: version
    type: u4
  - id: words
    type: u4
    repeat: eos
