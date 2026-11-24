meta:
  id: gda
  title: Sid Meier's Pirates! NANDBigFile.gda
  file-extension: gda
  endian: be
doc: |
  Back-to-back Gamebryo streams. Each entry is a raw "Gamebryo File Format,
  Version 20.6.0.0" NIF (length from its block table) or a compressed record
  {be32 parts (1..64), parts * {be32 compressed size, LZ11 stream (<= 32 KiB per
  part)}} whose concatenated output is a NIF or "Gamebryo KFM". Raw KFM blobs run
  to the next entry.
seq:
  - id: rest
    size-eos: true
types:
  compressed_record:
    seq:
      - id: parts
        type: u4
      - id: part_list
        type: part
        repeat: expr
        repeat-expr: parts
  part:
    seq:
      - id: compressed_size
        type: u4
      - id: lz11
        size: compressed_size
