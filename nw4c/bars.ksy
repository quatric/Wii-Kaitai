meta:
  id: bars
  file-extension: bars
  title: Nintendo Binary Audio Resource archive
doc: |
  A flat container of audio assets -- `BARS` -- each entry pairing an
  optional AMTA metadata chunk (which carries the asset's name) with an
  optional audio payload (BWAV or FWAV/BFWAV). Seen packed inside .bin
  containers as well as standalone .bars files.

  The header gives an asset count; right after it comes a name-hash table
  (one u32 per asset, used to look an asset up by hashed name without
  reading the AMTA chunks) and then a table of offset pairs, one per
  asset: the AMTA chunk's offset and the audio payload's offset. Either
  offset may be 0xffffffff for "not present". Both tables and every
  offset are absolute, from the start of the file.

  Endianness is a byte-order mark in the header, exactly like SARC/BFRES:
  0xfeff big-endian, 0xfffe little-endian.
seq:
  - id: magic
    contents: "BARS"
  - id: len_file_raw
    size: 4
    doc: |
      Total file size; its endianness is not known until `bom` (right
      after it) has been read, so it is kept as raw bytes here. See
      `content.len_file` for the value re-read with the correct endian.
  - id: bom
    type: u2be
    doc: 0xfeff for big-endian content, 0xfffe for little-endian.
  - id: content
    type:
      switch-on: bom
      cases:
        0xfeff: body(false)
        0xfffe: body(true)
types:
  body:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: version
        type: u2
      - id: num_assets
        type: u4
      - id: name_hashes
        type: u4
        repeat: expr
        repeat-expr: num_assets
      - id: pairs
        type: offset_pair
        repeat: expr
        repeat-expr: num_assets
    instances:
      len_file:
        pos: 4
        io: _root._io
        type: u4
        doc: Total file size, re-read from the header with the now-known endianness.
    types:
      offset_pair:
        seq:
          - id: ofs_amta
            type: u4
            doc: Offset of the AMTA metadata chunk, or 0xffffffff if absent.
          - id: ofs_audio
            type: u4
            doc: Offset of the audio payload (BWAV/FWAV), or 0xffffffff if absent.
        instances:
          has_amta:
            value: ofs_amta != 0xffffffff
          has_audio:
            value: ofs_audio != 0xffffffff
          amta:
            io: _root._io
            pos: ofs_amta
            size-eos: true
            if: has_amta
            doc: Raw AMTA chunk; its own magic/size/name-pointer fields are not modeled here.
          audio:
            io: _root._io
            pos: ofs_audio
            size-eos: true
            if: has_audio
            doc: Raw audio payload (BWAV or FWAV container); not modeled here.
