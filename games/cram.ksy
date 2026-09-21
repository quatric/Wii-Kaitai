meta:
  id: cram
  file-extension: arc
  endian: le
  title: Xenoblade Chronicles 3D "cram" archive (3DS)
doc: |
  Flat, named, uncompressed archive shipped in the 3DS remaster of
  Xenoblade Chronicles. Layout ported from aluigi's public
  `xenoblade_arc.bms` script (all fields little-endian): a 16-byte header,
  a fixed 16-byte-per-entry table, a parallel table of name offsets, and a
  NUL-terminated name blob.

  Every name additionally carries a CRC32 of itself in the entry table.
  The purpose of that checksum (a lookup hash, most likely) was not
  recovered from the samples available, so this structure only exposes it
  as a raw field -- do not assume it is validated against `name` when
  writing a modified archive back out.
seq:
  - id: magic
    contents: "cram"
  - id: num_files
    type: u4
  - id: dummy
    type: u4
    doc: Always 0x80 in every sample; purpose unknown.
  - id: ofs_names
    type: u4
    doc: |
      Absolute offset of the start of the name blob. Every entry in
      `name_offsets` is relative to this, not to the file.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
  - id: name_offsets
    type: u4
    repeat: expr
    repeat-expr: num_files
    doc: Per-entry offset into the name blob, relative to `ofs_names`.
instances:
  names:
    pos: ofs_names
    size-eos: true
    doc: Raw NUL-terminated name blob; `name_offsets` index into this substream.
types:
  entry:
    seq:
      - id: name_crc
        type: u4
        doc: |
          CRC32 of the entry's (NUL-less) name, as computed by the CRC-32
          used throughout zlib. Written by the tool that built the
          archive; the algorithm was confirmed by recomputation, but its
          use at load time (a lookup hash, presumably) was not recovered.
      - id: type
        type: str
        size: 4
        encoding: ASCII
        doc: File "type" tag, typically the extension without leading dot.
      - id: ofs_body
        type: u4
        doc: Absolute offset of this member's data.
      - id: len_body
        type: u4
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
