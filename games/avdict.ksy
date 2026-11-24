meta:
  id: avdict
  title: Avalanche DICT localisation dictionary (.dct, Disney's Bolt)
  file-extension: dct
  endian: le
doc: Hash tables then a pool of NUL-terminated UTF-8 strings (each text followed by its voice / string id).
seq:
  - id: magic
    contents: DICT
  - id: x2000
    type: u4
  - id: hash
    type: u4
  - id: version
    type: u4
  - id: rest
    size-eos: true
