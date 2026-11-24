meta:
  id: spxogg
  title: Ogg Speex (.spx) pages and header
  file-extension: spx
  endian: le
doc: |
  Ogg pages re-assemble into packets: packet 0 is the 80-byte "Speex   "
  header, packet 1 the comment header, the rest Speex frame groups.
seq:
  - id: pages
    type: page
    repeat: expr
    repeat-expr: 1
    doc: First page only (body length is the segment table sum).
types:
  page:
    seq:
      - id: magic
        contents: OggS
      - id: version
        type: u1
      - id: header_type
        type: u1
      - id: granule_position
        type: u8
      - id: serial
        type: u4
      - id: sequence
        type: u4
      - id: crc
        type: u4
      - id: segment_count
        type: u1
      - id: segment_table
        type: u1
        repeat: expr
        repeat-expr: segment_count
        doc: |
          The body that follows is sum(segment_table) bytes; Kaitai cannot sum
          this inline, so the body is left to the next page's parse by the caller.
  speex_header:
    seq:
      - id: magic
        contents: "Speex   "
      - id: version_string
        size: 20
      - id: version_id
        type: s4
      - id: header_size
        type: s4
      - id: rate
        type: s4
      - id: mode
        type: s4
      - id: mode_bitstream_version
        type: s4
      - id: channels
        type: s4
      - id: bitrate
        type: s4
      - id: frame_size
        type: s4
      - id: vbr
        type: s4
      - id: frames_per_packet
        type: s4
      - id: extra_headers
        type: s4
      - id: reserved
        size: 8
