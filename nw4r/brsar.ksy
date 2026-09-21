meta:
  id: brsar
  file-extension: brsar
  endian: be
  title: NW4R RSAR Wii sound archive
doc: |
  The Wii `RSAR` sound-archive container: a fixed 0x40-byte header whose
  three payload blocks (`SYMB` the name/string table, `INFO` the
  sound/bank/group tables, `FILE` the raw payload blobs) are each an
  offset+size pair at a fixed slot in the header. Field layout verified
  against `lib-brsar.c`'s `UnpackBRSAR()`/`WriteRsarEnvelope()`, itself
  taken from vgmtrans' `RSARScanner.cpp`.

  The related Wii U `FSAR` and 3DS `CSAR` archives share the same three
  named blocks but wrap them in a BFSTM/BCSTM-style section table instead
  of this fixed header; `lib-brsar.c` explicitly documents that its
  handling of those two variants is an untested extrapolation rather than
  something verified against a real reader, so they are intentionally
  not modeled here.

  Only the SYMB/INFO/FILE envelope is modeled; the internal structure of
  the RSEQ/RBNK/RWAR/RWSD payloads those blocks describe is out of scope
  (`lib-brsar.c` itself treats most of it as opaque pass-through).
seq:
  - id: magic
    contents: "RSAR"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 0x0104 in practice.
  - id: len_file
    type: u4
  - id: len_header
    type: u2
    doc: 0x40 in practice.
  - id: num_blocks
    type: u2
    doc: Always 3 (SYMB, INFO, FILE).
  - id: symb_off
    type: u4
  - id: len_symb
    type: u4
  - id: info_off
    type: u4
  - id: len_info
    type: u4
  - id: file_off
    type: u4
  - id: len_file_block
    type: u4
instances:
  symb:
    pos: symb_off
    size: len_symb
    type: block
  info:
    pos: info_off
    size: len_info
    type: block
  file:
    pos: file_off
    size: len_file_block
    type: block
types:
  block:
    doc: |
      Common `SYMB`/`INFO`/`FILE` block header: a 4-byte tag plus the
      size of the whole block (tag included), followed by block-specific
      content this definition does not decode further.
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: len_block
        type: u4
      - id: body
        size: len_block - 8
