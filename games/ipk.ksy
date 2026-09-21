meta:
  id: ipk
  file-extension: ipk
  endian: be
  title: Ubisoft UbiArt IPK archive
doc: |
  Ubisoft UbiArt engine archive (Just Dance, Rayman Origins/Legends, Child
  of Light; Wii/Wii U/Switch/PC). A 0x30-byte header is followed by a
  variable-length directory of per-file records, ending exactly at
  `base_offset` where the data area begins. Two on-disk strings (path and
  name) exist per entry, but their order is not fixed by any header flag --
  older titles store name first, newer ones store path first -- so callers
  must apply a heuristic (the slash-bearing string is the path, the
  dotted one is the name) to tell them apart; that assignment is left to
  readers of this definition. Ported from lib-ipk.c's `ScanIPK`.
seq:
  - id: magic
    contents: [0x50, 0xec, 0x12, 0xba]
  - id: version
    type: u4
    doc: 3, 5 or 7 observed.
  - id: platform
    type: u4
  - id: base_offset
    type: u4
    doc: Absolute start of the data area; the directory must end exactly here.
  - id: num_files
    type: u4
  - id: tail
    type: u4
    repeat: expr
    repeat-expr: 7
    doc: |
      Version-dependent extra fields (compressed/binaryscene/binarylogic/
      datasignature/enginesignature/engineversion/num_files2 on newer
      titles); opaque on v3 and never validated by the reader.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: flag1
        type: u4
        doc: 1 normally; 2 means `extra` (8 bytes) follows.
      - id: len_body
        type: u4
        doc: Uncompressed size.
      - id: len_stored
        type: u4
        doc: Stored (possibly compressed) size; 0 means stored uncompressed at `len_body`.
      - id: timestamp
        type: u8
      - id: ofs_body
        type: u8
        doc: Offset of the stored bytes, relative to the file's `base_offset`.
      - id: extra
        size: 8
        if: flag1 == 2
      - id: len_s1
        type: u4
      - id: s1
        type: str
        size: len_s1
        encoding: UTF-8
      - id: len_s2
        type: u4
      - id: s2
        type: str
        size: len_s2
        encoding: UTF-8
      - id: crc
        type: u4
        doc: Jenkins-style path hash; never validated by the reader.
      - id: flag2
        type: u4
        doc: 0 normally, 2 for .ckd members.
    instances:
      body:
        io: _root._io
        pos: _root.base_offset + ofs_body
        size: 'len_stored != 0 ? len_stored : len_body'
        doc: |
          Stored bytes: zlib- or LZMA-compressed when `len_stored` is
          nonzero and differs from `len_body`, otherwise raw.
