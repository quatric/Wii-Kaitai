meta:
  id: lracp
  title: Line Rider Freestyle animated-character pack (.acp)
  file-extension: acp
  endian: be
doc: '{u32 count, ...settings...} with a table of count + 1 u32 offsets ending where the first "LRMH" chunk starts; the last entry is the file size.'
seq:
  - id: count
    type: u4
  - id: rest
    size-eos: true
