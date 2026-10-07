meta:
  id: bmg_le
  title: Nintendo little-endian BMG (GSEM1gmb / .cbmg / .mlz inner)
  file-extension: cbmg
  endian: le
doc: |
  The little-endian compilation of the Nintendo Binary Message (BMG)
  format used by Nintendo DS titles such as Custom Robo Arena (`.cbmg`, and
  `.mlz` which are LZ10-compressed BMG). Verified on 8 `.cbmg` scripts and 680
  `.mlz` archives, all of which decode and re-encode byte for byte.

  Compared to the big-endian `MESGbmg1` form the magic is byte-reversed
  (`GSEM1gmb` -> `MESG` `bmg1` as little-endian dwords) and so are the
  section tags: `INF1` -> `1FNI`, `DAT1` -> `1TAD`, `MID1` -> `1DIM`, `STR1`
  -> `1RTS`, `FLW1` -> `1WLF`, `FLI1` -> `1ILF`, `TBN1` -> `1NBT`,
  `WII1` -> `1IIW` (also `INF2` -> `2FNI`). Custom Robo Arena uses encoding 3
  (Shift-JIS) with variable attributes and escape codes (`\z{...}`).
seq:
  - id: magic
    contents: 'GSEM1gmb'
  - id: file_size
    type: u4
  - id: num_sections
    type: u4
  - id: encoding
    type: u1
    enum: encoding
  - id: reserved
    size: 15
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
        doc: Size of the whole section, including the 8-byte tag/size header.
      - id: body
        size: size - 8
        type:
          switch-on: tag
          cases:
            '"1FNI"': inf
            '"2FNI"': inf
            '"1TAD"': dat
            '"1DIM"': mid
  inf:
    seq:
      - id: num_messages
        type: u2
      - id: item_size
        type: u2
        doc: Size of each item (offset, then attribute bytes).
      - id: unknown_0c
        type: u4
      - id: items
        type: item
        repeat: expr
        repeat-expr: num_messages
  item:
    seq:
      - id: text_offset
        type: u4
        doc: Offset into the `1TAD` text pool.
      - id: attributes
        size: _parent.item_size - 4
  dat:
    seq:
      - id: text_pool
        size-eos: true
        doc: Message strings in the file's `encoding`.
  mid:
    seq:
      - id: num_messages
        type: u2
      - id: unknown_0a
        type: u2
        doc: 0x1000 in Mario Kart Wii.
      - id: unknown_0c
        type: u4
      - id: message_ids
        type: u4
        repeat: expr
        repeat-expr: num_messages
enums:
  encoding:
    0: undefined
    1: cp1252
    2: utf16
    3: shift_jis
    4: utf8
