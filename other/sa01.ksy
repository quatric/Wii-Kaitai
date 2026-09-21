meta:
  id: sa01
  endian: be
  title: Nintendo SA01/CA01 archive (Mii Maker / amiibo settings)
doc: |
  Nintendo "SA01" (named) / "CA01" (unnamed) flat archive, per
  ScanSA01() in lib-sa01.c. The reference reader has no fixed
  endianness tag and instead guesses byte order from whichever
  interpretation yields a sane file count (<= 0x10000); this
  definition assumes the big-endian (Mii Maker) convention noted in
  the source as the common case. Amiibo-derived files may need the
  little-endian counterpart instead.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"SA01"', '"CA01"']
  - id: num_files
    type: u4
  - id: base_offset
    type: u4
instances:
  is_named:
    value: magic == "SA01"
  offsets:
    type: u4
    repeat: expr
    repeat-expr: num_files
  sizes:
    type: u4
    repeat: expr
    repeat-expr: num_files
  names:
    type: str
    size: 0x80
    encoding: ASCII
    terminator: 0
    repeat: expr
    repeat-expr: 'is_named ? num_files : 0'
