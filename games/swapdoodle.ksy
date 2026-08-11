meta:
  id: swapdoodle
  file-extension: bin
  application: Swapdoodle / Swapnote (Nintendo 3DS)
  endian: le
seq:
  - id: magic
    contents: "BPK1"
    doc: |
      BPK1 is the chunk container used by Swapdoodle note files after the
      optional Nintendo LZ10 wrapper has been decompressed. Directory entries
      are ordered and names may repeat (notably one SHEET1 and THUMB2 per
      page), so consumers must not collapse the directory to a map.

      This definition covers the recovered structured payloads. Other BPK1
      chunks are retained as raw bytes: their directory offset, size, and
      stored hash are authoritative even when their inner format is unknown.
  - id: entry_count
    type: u4
  - id: version
    type: u4
    doc: Observed value is 7.
  - id: file_size
    type: u4
  - id: payload_offset
    type: u4
    doc: Offset of the first payload; normally 16-byte aligned.
  - id: reserved
    size: 44
    doc: Bytes 0x14..0x3f are preserved by the application.
  - id: entries
    type: directory_entry
    repeat: expr
    repeat-expr: entry_count
types:
  directory_entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: hash
        type: u4
        doc: Per-payload hash. It is not standard CRC-32.
      - id: name
        type: str
        size: 8
        encoding: ASCII
        terminator: 0
        include: false
    instances:
      payload_at_offset:
        pos: offset
        size: size
        type:
          switch-on: name
          cases:
            "'SHEET1'": sheet1
            "'BADGE1'": badge1
            "'CHRBRD1'": chrbrd1
            "'BPK1'": swapdoodle
            _: raw_payload
        doc: |
          Payloads are addressed by this directory offset rather than stored
          after the directory records; entries are normally 4-byte aligned.
  raw_payload:
    seq:
      - id: data
        size-eos: true
  sheet1:
    doc: |
      Vector ink page. The first u32 record is a page-specific lead value;
      remaining records are packed coordinates, pen state, and image stamps.
    seq:
      - id: capacity
        type: u4
      - id: record_count
        type: u4
      - id: header_padding
        size: 56
      - id: lead
        type: u4
        if: record_count > 0
      - id: records
        type: sheet_record
        repeat: expr
        repeat-expr: record_count - 1
        if: record_count > 0
  sheet_record:
    seq:
      - id: raw
        type: u4
    instances:
      kind:
        value: raw & 0xf
      y:
        value: (raw >> 4) & 0xff
      x:
        value: (raw >> 12) & 0xff
      pen_style:
        value: (raw >> 21) & 1
      pen_down:
        value: (raw >> 22) & 1
      continuation:
        value: (raw >> 23) & 1
        doc: Incremental-record bookkeeping; not a pen-style bit.
      pen_color_index:
        value: (raw >> 24) & 7
      thick_pen:
        value: (raw >> 27) & 1
      badge_index:
        value: (raw >> 22) & 3
        doc: Used only by kind 0x0d badge-placement records.
  badge1:
    doc: |
      PICA200 8x8 Morton-tiled RGB565 colour plane followed by a matching A4
      alpha plane. The remaining bytes are fixed-size padding to 41024 bytes.
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: padded_width
        type: u2
      - id: padded_height
        type: u2
      - id: badge_id
        type: u4
      - id: set_id
        type: u4
      - id: constant_c8
        type: u4
      - id: unknown_14
        type: u4
      - id: index
        type: u4
        doc: Selected by SHEET1 badge_index, not a page number.
      - id: reserved
        size: 36
      - id: rgb565_morton
        size: width * height * 2
      - id: alpha4_morton
        size: width * height / 2
      - id: padding
        size-eos: true
  chrbrd1:
    doc: "Sender character-board portrait: 64x128 PICA200 Morton-tiled RGBA4."
    seq:
      - id: header
        size: 16
      - id: rgba4_morton
        size: 16384
