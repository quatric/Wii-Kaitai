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

  The inner archive can be stored directly, inside a `ZCMP` wrapper with a
  0x80-byte prelude and zlib stream, or behind a four-byte big-endian output
  length followed by zlib. The latter wrapper is accepted only when its
  declared length is non-zero, within the tool's output cap, and not smaller
  than the compressed remainder. Both compressed forms must inflate to an
  inner `SA01` or `CA01` image.

  For the inner image, offsets are relative to `base_offset`; adding that
  base gives the member's absolute position. The count must be 1..0x10000,
  and the complete offset, size, and (for SA01) name tables must fit. The
  reader skips out-of-range members and rejects an archive with no valid
  members. SA01 names are fixed 0x80-byte, NUL-padded slots; unsafe names are
  replaced with numbered `.bin` names. CA01 has no name table and extracts
  numbered `.sar` members.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"SA01"', '"CA01"']
  - id: num_files
    type: u4
    doc: Number of member offsets and sizes. This definition reads big-endian;
      nintoolbox falls back to little-endian when only that count is plausible.
  - id: base_offset
    type: u4
    doc: Base added to each stored relative member offset.
instances:
  is_named:
    value: magic == "SA01"
  offsets:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: 12
    doc: Relative member offsets, indexed in parallel with sizes and names.
  sizes:
    type: u4
    repeat: expr
    repeat-expr: num_files
    pos: 12 + num_files * 4
    doc: Stored member byte lengths.
  names:
    type: str
    size: 0x80
    encoding: ASCII
    terminator: 0
    repeat: expr
    repeat-expr: 'is_named ? num_files : 0'
    pos: 12 + num_files * 8
    doc: SA01's fixed-width member names. Absent in CA01.
