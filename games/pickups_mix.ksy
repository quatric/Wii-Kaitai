meta:
  id: pickups_mix
  title: Super PickUps CARS.MIX
  file-extension: mix
  endian: be
doc: |
  Super PickUps (Wii) `CARS.MIX`. The header is padded to 0x20; the table at the
  end of the file holds entries parsed sequentially to the end of the file.
  Names are obfuscated.
seq:
  - id: zero
    type: u4
  - id: num_files
    type: u4
  - id: table_offset
    type: u4
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: len_name
        type: u4
        doc: 0x15 and up.
      - id: name_obfuscated
        size: len_name
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: len_data_again
        type: u4
      - id: trailer
        size: 9
