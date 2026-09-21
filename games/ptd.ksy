meta:
  id: ptd
  title: GameCube/Wii PTD DSP-ADPCM sound container
  file-extension: ptd
  endian: be
  license: CC0-1.0

doc: |
  GameCube/Wii audio archive of DSP-ADPCM streams, one or two channels each.
  A stream whose flags word equals 23871488 (0x016C3F80) carries an extra
  144-byte unknown data blob after its channel headers.

  Reference: nintoolbox project/src/lib-ptd.c/.h (ScanPTDFile / CreatePTD),
  matching MPLibrary/GCWii/Audio/PTD.cs PtdFile::Read/Write.

seq:
  - id: version
    type: u2
    doc: 1 or 2.
  - id: num_files
    type: u2
  - id: unknown2
    type: u4
  - id: sample_rate
    type: u4
  - id: channel_count
    type: u4
  - id: entry_offsets_offset
    type: u4
    doc: Always 32 in files this project produces.
  - id: coef_offset
    type: u4
  - id: header_offset
    type: u4
  - id: stream_base_offset
    type: u4

instances:
  entry_offsets:
    pos: entry_offsets_offset
    type: u4
    repeat: expr
    repeat-expr: num_files
  streams:
    doc: |
      One slot per num_files entry. entry_offsets[i] == 0 marks an empty
      slot (no stream header present at all); non-empty slots hold a
      stream_header at that file offset.
    type: stream_slot(_index)
    repeat: expr
    repeat-expr: num_files

types:
  stream_slot:
    params:
      - id: idx
        type: u4
    instances:
      file_offset:
        value: _root.entry_offsets[idx]
      header:
        pos: file_offset
        type: stream_header
        if: file_offset != 0

  stream_header:
    doc: |
      Per-file header. Followed by an 8-byte second-channel block only when
      `flags & 0x01000000` (stereo), then, if flags == 0x016C3F80, a
      144-byte unknown data blob.
    seq:
      - id: flags
        type: u4
      - id: sample_rate
        type: u4
      - id: nibble_count
        type: u4
      - id: loop_start
        type: u4
      - id: ch1_stream_offset
        type: u4
      - id: ch1_coef_index
        type: u2
      - id: ch1_unknown
        type: u2
      - id: ch2
        type: stereo_extra
        if: is_stereo
    instances:
      is_stereo:
        value: (flags & 0x01000000) != 0
      has_unknown_block:
        value: flags == 0x016C3F80

  stereo_extra:
    seq:
      - id: ch2_stream_offset
        type: u4
      - id: ch2_coef_index
        type: u2
      - id: ch2_unknown
        type: u2

  coef_table_entry:
    doc: 16 s16 DSP-ADPCM coefficients, 32 bytes.
    seq:
      - id: coef
        type: s2
        repeat: expr
        repeat-expr: 16
