meta:
  id: toshi_tsfb
  endian: be
  title: Blue Tongue Toshi engine TSFB/TRB container (Nicktoons, Wii)
doc: |
  Blue Tongue "Toshi" engine TSFB container, per lib-toshi.h (ported
  from OpenBarnyard TTRB.h/TCompress_Decompress.cpp). A tagged hunk
  stream; the BTEC compression codec used by "CCES" hunks and the
  .ttl texture-library payload documented in the source are not
  modeled here.
seq:
  - id: magic
    contents: "TSFB"
  - id: file_size_minus_8
    type: u4
  - id: magic2
    contents: "FBRT"
  - id: hunks
    type: hunk_t
    repeat: eos
types:
  hunk_t:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
        doc: '"XRDH" header, "TCES"/"CCES" section, "CLER" relocations, "BMYS" symbols.'
      - id: size
        type: u4
      - id: body
        size: size
      - id: padding
        size: (4 - (size % 4)) % 4
