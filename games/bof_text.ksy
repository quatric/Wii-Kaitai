meta:
  id: bof_text
  title: Battle of Giants language table (.bof)
  file-extension: bof
  endian: le
doc: |
  Battle of Giants: Dinosaurs Strike (Wii) language table (one per language).
  `num_units` UTF-16LE units hold exactly `num_strings` NUL-terminated strings
  (speaker names and abbreviations, then runs of `{text key "txt_TRex", voice
  id "VO_CHA_001", text}`), followed by an index table of 12-byte records
  `{u32 unit offset, u32 id, u32 1}` (whose offsets refer to the English
  layout) and a tail nintoolbox leaves raw.
seq:
  - id: version
    type: u4
    doc: 1.
  - id: num_strings
    type: u4
  - id: num_units
    type: u4
  - id: text_units
    size: num_units * 2
  - id: tail
    size-eos: true
