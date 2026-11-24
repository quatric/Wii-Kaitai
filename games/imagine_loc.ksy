meta:
  id: imagine_loc
  title: Ubisoft Imagine LOCV1.0 localisation table (.LOC)
  file-extension: loc
  endian: le
doc: |
  Ubisoft Imagine `LOCV1.0` localisation table (Beastly, Babysitting Party,
  Babyz; the `.LOC` files are LZSS wrapped, see `imagine_lz`). Little-endian u32
  string offsets start at 0x10 up to the first string (the table end is the
  smallest 4-aligned offset equal to `0x10 + 4 * index`; a few leading entries
  point at zero bytes inside the table and are empty strings), followed by
  NUL-terminated Latin-1 texts.
seq:
  - id: magic
    contents: '.LOCV1.0'
  - id: id
    type: u4
  - id: language_tag
    size: 4
    type: strz
    encoding: ASCII
    doc: '`!DE`'
