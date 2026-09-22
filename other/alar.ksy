meta:
  id: alar
  file-extension: alar
  endian: le
  title: Jump Ultimate Stars archive (ALAR)
doc: |
  A small flat archive from *Jump Ultimate Stars* (DS). A fixed 16-byte
  header is followed by a table of 16-byte entries; each entry's payload
  offset/size are known (bytes 4..8 and 8..12 of the entry), the rest of
  the entry layout is not reverse-engineered here -- the reference tool
  only ever decodes entry 0.

  `num_files` overlaps two layouts at header offset 6: for `archive_type`
  2 it is a u2, for `archive_type` 3 it is a u4. The header is a fixed 16
  bytes either way; the entry table starts right after it.

  nintoolbox's DecodeALAR is not a general archive extractor: it returns
  only entry zero's raw payload. Type 2 requires a nonzero count and a
  complete count*16 descriptor table. Type 3 requires only a nonzero
  count and at least 32 file bytes; later descriptors are never checked.
  In both cases, entry zero must have a nonzero length and a payload range
  within the file. Unknown type values are rejected. This schema models
  the nominal complete descriptor array, so a type 3 file accepted by
  the reference decoder may still fail to parse here if its advertised
  later entries are absent. No decompression or filename interpretation
  is performed by DecodeALAR.
seq:
  - id: magic
    contents: "ALAR"
  - id: archive_type
    type: u1
    enum: alar_type
    doc: Chooses the width of the overlapping file-count field at offset 6.
  - id: unknown1
    type: u1
  - id: header_tail
    size: 10
    doc: |
      Bytes 6..16 of the header: `num_files` (u2 for type 2, u4 for type
      3, both little-endian) plus trailing padding, kept raw here -- see
      `num_files`.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
    doc: Nominal 16-byte descriptors; reference decoder reads only entry zero.
instances:
  num_files:
    value: |
      archive_type == alar_type::type3
        ? header_tail[0] | (header_tail[1] << 8) | (header_tail[2] << 16) | (header_tail[3] << 24)
        : header_tail[0] | (header_tail[1] << 8)
types:
  entry:
    seq:
      - id: unknown1
        type: u4
        doc: Not reverse-engineered; unused by the reference extractor.
      - id: ofs_body
        type: u4
        doc: Absolute byte offset of this entry's raw payload.
      - id: len_body
        type: u4
        doc: Raw payload byte length; entry zero must be nonempty to decode.
      - id: unknown2
        type: u4
        doc: Not reverse-engineered; unused by the reference extractor.
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        if: len_body > 0
        doc: Raw member bytes; no transform is applied by DecodeALAR.
enums:
  alar_type:
    2: type2
    3: type3
