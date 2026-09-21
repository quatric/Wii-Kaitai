meta:
  id: mtxt
  endian: le
  title: Nintendo Switch MTXT texture archive
doc: |
  Nintendo Switch "MTXT" texture archive (.mtxt), as read by
  ExtractMTXTArchive()/CreateMTXTArchive() in lib-nintendo-archives.c.
  A 4-byte magic and a flags word, followed by a gzip stream whose
  decompressed payload is normally an inner XTX ("DFvN") texture
  container (Tegra block-linear surfaces); if the payload isn't
  recognized as XTX it is treated as an opaque blob.
seq:
  - id: magic
    contents: "MTXT"
  - id: flags
    type: u4
  - id: gzip_payload
    size-eos: true
    doc: |
      Gzip-wrapped stream (zlib inflate with gzip/window auto-detect);
      decompresses to an XTX texture container in retail files.
