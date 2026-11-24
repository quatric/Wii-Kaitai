meta:
  id: darpack
  title: Gaijin Games Core.dar (Bit.Trip Complete)
  file-extension: dar
  endian: be
doc: |
  {"DAR" + 29 x 'a', 0x20 bytes}, then standard Nintendo resource files back to
  back, each padded to 0x20: files with a BOM at +4 and size at +8 (REFF, REFT,
  RFNT, ...) and "U.8" archives (size taken from the end of the last member).
seq:
  - id: magic
    size: 0x20
  - id: members
    size-eos: true
