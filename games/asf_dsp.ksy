meta:
  id: asf_dsp
  title: Multi-stream DSP-ADPCM container (.asf)
  file-extension: asf
  endian: le
doc: |
  Multi-stream DSP-ADPCM container (Brunswick Pro Bowling, Celebrity Sports
  Showdown and relatives, Wii): a little-endian wrapper around big-endian DSP
  headers. Records at `0x0c + 0x70 * i`. The `{offset, size}` pair at +0x68
  describes the *next* stream; the first stream is at the data start. Records
  flagged 0x0202 are stereo: the header describes one channel, both channels
  share it and the data is interleaved in 0x4000-byte blocks.
seq:
  - id: num_streams
    type: u4
  - id: data_start
    type: u4
  - id: len_first_stream
    type: u4
  - id: records
    type: record
    repeat: expr
    repeat-expr: num_streams
types:
  record:
    seq:
      - id: flags
        type: u4
        doc: 0x0201 mono, 0x0202 stereo.
      - id: name
        size: 4
      - id: dsp_header
        size: 0x60
        doc: Standard big-endian GameCube DSP header.
      - id: next_offset
        type: u4
      - id: next_size
        type: u4
