meta:
  id: gfmc
  title: Kirby's Return to Dream Land GFMC message file
  file-extension: bin
  endian: be
doc: |
  "GFMC" message file of the Teolsil / HAL Kirby game (Kirby's Return to Dream
  Land, `message/<lang>/*.bin`). A 0x1c-byte header gives four section
  offsets:

  * `sec1` (= 0x1c) -- unused by the extractor.
  * `sec2` -- `{u4 label_hash, u4 count, u4 sec3_offset}` records.
  * `sec3` -- `u4` offsets into the string pool.
  * `sec4` -- the string pool.

  A string slot in the pool is a run of 16-bit control words that ends with the
  pair `0x5458 0x0000` (`"TX\0\0"`), then a `u2` character count and that many
  UTF-16BE characters, followed by trailing control words. nintoolbox writes
  `[hash]` blocks as UTF-8.
seq:
  - id: magic
    contents: 'GFMC'
  - id: version
    type: u4
    doc: 0x10000.
  - id: file_size
    type: u4
  - id: sec1_offset
    type: u4
  - id: sec2_offset
    type: u4
  - id: sec3_offset
    type: u4
  - id: sec4_offset
    type: u4
instances:
  labels:
    pos: sec2_offset
    type: label
    repeat: expr
    repeat-expr: (sec3_offset - sec2_offset) / 12
  string_offsets:
    pos: sec3_offset
    type: u4
    repeat: expr
    repeat-expr: (sec4_offset - sec3_offset) / 4
types:
  label:
    seq:
      - id: label_hash
        type: u4
      - id: count
        type: u4
      - id: sec3_index_offset
        type: u4
        doc: Byte offset into `sec3` of the first string offset for this label.
  slot:
    doc: |
      One string slot. Address it with `pos: _root.sec4_offset + string_offsets[i]`.
    seq:
      - id: control_words
        type: control_word
        repeat: until
        repeat-until: _.value == 0x5458 and _.following == 0
      - id: terminator
        type: u2
        doc: The 0 that follows `0x5458`.
      - id: length
        type: u2
        doc: Character count.
      - id: text
        type: str
        size: length * 2
        encoding: UTF-16BE
  control_word:
    seq:
      - id: value
        type: u2
    instances:
      following:
        pos: _io.pos
        type: u2
