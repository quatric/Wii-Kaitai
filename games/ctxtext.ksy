meta:
  id: ctxtext
  title: Top Model Academy interface/texts.ctx localisation table
  file-extension: ctx
  endian: be
doc: |
  u32 strings per language, u32 highest id + 1 (approx.), u32 language count, then
  per language {u32 name length, name ("ger", "eng"), u32 block offset}; language
  blocks follow back to back, each holding <count> records {u32 id, u32 length in
  UTF-16 units, UTF-16BE text without terminator}.
seq:
  - id: strings_per_language
    type: u4
  - id: highest_id_plus_one
    type: u4
  - id: language_count
    type: u4
  - id: languages
    type: language
    repeat: expr
    repeat-expr: language_count
  - id: blocks
    size-eos: true
types:
  language:
    seq:
      - id: name_length
        type: u4
      - id: name
        size: name_length
        type: str
        encoding: ASCII
      - id: block_offset
        type: u4
  record:
    seq:
      - id: id
        type: u4
      - id: length
        type: u4
      - id: text
        size: length * 2
        type: str
        encoding: UTF-16BE
