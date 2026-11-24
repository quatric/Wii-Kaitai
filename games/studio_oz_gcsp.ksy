meta:
  id: studio_oz_gcsp
  title: THQ Australia GameCube sound bank (.sounds)
  file-extension: sounds
  endian: be
doc: |
  THQ Australia (Studio Oz) GameCube sound bank (SpongeBob Lights, Camera,
  Pants!, Jimmy Neutron Twonkies). With names, each name is a stream and an
  unnamed following file is its right channel; 22050 Hz fixed.
seq:
  - id: magic
    contents: gcsp
  - id: reserved0
    size: 8
  - id: data_start
    type: u4
  - id: reserved1
    size: 4
  - id: num_files
    type: u4
  - id: num_names
    type: u4
  - id: reserved2
    size: 4
  - id: files
    type: file_entry
    repeat: expr
    repeat-expr: num_files
  - id: names
    type: name_entry
    repeat: expr
    repeat-expr: num_names
types:
  file_entry:
    seq:
      - id: reserved0
        size: 0xc
      - id: num_nibbles
        type: u4
      - id: dsp_coefficients
        size: 0x20
      - id: reserved1
        size: 4
      - id: history
        size: 4
      - id: reserved2
        size: 8
      - id: next_start_offset
        type: u4
        doc: File 0 starts at the data start.
  name_entry:
    seq:
      - id: file_id
        type: u4
      - id: rest
        size: 0x18
