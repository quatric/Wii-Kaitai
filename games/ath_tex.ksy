meta:
  id: ath_tex
  title: International Athletics .TEX texture
  file-extension: tex
  endian: be
doc: |
  International Athletics `.TEX` texture (a `PAK\3` member; see `pak3`). The
  file ends exactly after the data. C4 / C8: a 16-bit RGB5A3 palette first, then
  the GX-tiled indices. Rows are stored bottom-up.
seq:
  - id: magic_word
    type: u4
    doc: 0x04020000 or 0x04027400.
  - id: format
    type: u4
    enum: format
  - id: len_data
    type: u4
  - id: width
    type: u4
  - id: height
    type: u4
  - id: one
    type: u4
  - id: data
    size: len_data
enums:
  format:
    9: c4
    10: c8
    11: rgb5a3
    13: cmpr
