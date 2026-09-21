meta:
  id: zlarc
  endian: be
  title: NES Remix indieszero archive (.zlarc)
doc: |
  indieszero's NES Remix archive container. The outer file is one ordinary
  zlib stream; its decompressed bytes are an offset directory, variable-size
  descriptors, and concatenated member data. There is no magic inside the
  decompressed body, so a caller must identify the outer file by context or
  extension rather than signature.

  nintoolbox accepts at most 100,000 entries, requires the first descriptor
  offset to follow the directory, calculates the data area as the greatest
  `descriptor_offset + 12 + name_length`, and treats each descriptor's
  `data_offset` as relative to that calculated data area. It clamps an
  out-of-range member size to EOF. The writer sorts inputs, drops directory
  components from their names, writes descriptors consecutively after the
  directory, and writes NUL-terminated basenames.

  A 37,882-byte retail `hankotga.zlarc` from Wii U NES Remix Pack inflates to
  4,968,395 bytes and contains 100 descriptors. This definition parses its
  zlib form directly; malformed raw-DEFLATE compatibility streams, if any,
  are outside the writer and reader contract documented here.
seq:
  - id: raw
    size-eos: true
    process: zlib
    type: body_t
    doc: Entire zlib-compressed file, transformed into the uncompressed archive
      body before parsing.
types:
  body_t:
    seq:
      - id: num_entries
        type: u4
        doc: Number of directory offsets and member descriptors.
      - id: descriptor_offsets
        type: descriptor_offset_t
        repeat: expr
        repeat-expr: num_entries
        doc: Offset-directory records, each resolving its descriptor through
          its own absolute offset.

  descriptor_offset_t:
    seq:
      - id: value
        type: u4
        doc: Absolute descriptor offset within the decompressed archive body.
    instances:
      descriptor:
        type: descriptor_t
        pos: value
        doc: Variable-size descriptor selected through this directory slot.
  descriptor_t:
    seq:
      - id: data_offset
        type: u4
        doc: Offset of this member relative to the decompressed data area, not
          relative to the beginning of the archive.
      - id: data_size
        type: u4
        doc: Stored byte length of this member before reader-side EOF clamping.
      - id: name_length
        type: u4
        doc: Length in bytes of `name`, including the writer's trailing NUL.
      - id: name
        type: str
        size: name_length
        encoding: UTF-8
        doc: Filename bytes. Canonical writer output is a NUL-terminated
          basename; the reader removes any trailing NULs before extraction.
