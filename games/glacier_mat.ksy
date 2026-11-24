meta:
  id: glacier_mat
  title: IO Interactive Glacier material library (.MAT)
  file-extension: mat
  endian: be
doc: |
  Mini Ninjas. Tagged typed-object stream: a header {u32 offsets..} followed by
  schema records {fourcc tag, u32 value or offset, u16 size, u16 kind} (NAME,
  TYPE, PATH, IDEN, SUBC, CLAS, ENAB, BENA, BMOD, OPAC, ATST, AREF, CULL, ZBIA,
  ZOFF, TXID, TILU, TILV, RSTA, TEXT, SCRL, BIND, INST ...) and instance
  records, one per material, starting with the NUL-terminated material name
  followed by its property tags. A TXID record whose kind words are {1, 2} holds
  an inline texture id (ids count up from 128 in a bank).
seq:
  - id: rest
    size-eos: true
types:
  schema_record:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: value_or_offset
        type: u4
      - id: size
        type: u2
      - id: kind
        type: u2
