meta:
  id: epg
  file-extension: .bin
  endian: be
doc: >-
  TV no Tomo HDPK `001B` electronic-program-guide package.  All directory
  pointers in this file are stored relative to byte 0x20 and are therefore
  resolved with `+ 32`.  It is a hierarchy of channels, program pointers, and
  fixed 0x18-byte program records, plus a second timed auxiliary directory.

seq:
  - id: magic
    contents: "HDPK"
    doc: HDPK container signature.
  - id: type
    contents: "001B"
    doc: TV-guide package type code.
  - id: file_length
    type: u4
    doc: Producer-declared complete file size.
  - id: pointer_table_offset
    type: u4
    doc: 0x20-relative offset of the common pointer table.
  - id: pointer_table_size
    type: u4
    doc: Number of 4-byte common-pointer entries.
  - id: unknown
    type: u4
    doc: Unrecovered common HDPK header word at 0x14.
  - id: footer_size
    type: u4
    doc: Producer-declared footer byte length.
  - id: unknown1
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown2
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown3
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown4
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown5
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown6
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: unknown7
    type: u4
    doc: Unrecovered common HDPK header word.
  - id: region_code
    type: u2
    doc: Geographic/program-guide region code.
  - id: unk
    type: u2
    doc: Unrecovered 16-bit field paired with region_code.
  - id: number_of_channels
    type: u4
    doc: Number of 12-byte channel directory entries.
  - id: channel_table_offset
    type: u4
    doc: 0x20-relative offset of the channel directory.
  - id: number_of_unk
    type: u4
    doc: Number of timed auxiliary-directory entries.
  - id: offset_to_unk
    type: u4
    doc: 0x20-relative offset of the timed auxiliary directory.
    
instances:
  pointer_table:
    pos: pointer_table_offset + 32
    type: pointer_table
    repeat: expr
    repeat-expr: pointer_table_size
    doc: Common 0x20-relative pointer directory.
    
  channel_table:
    pos: channel_table_offset + 32
    type: channel_table
    repeat: expr
    repeat-expr: number_of_channels
    doc: Channel directory, each entry leading to a program-pointer run.
    
  unk_table:
    pos: offset_to_unk + 32
    type: unknown_table
    repeat: expr
    repeat-expr: number_of_unk
    doc: Timed auxiliary directory with an attached nested record run.
    
types:
  channel_table:
    seq:
      - id: broadcast_type
        type: u2
        enum: broadcast_type
        doc: Broadcast medium/type code.
      - id: channel_number
        type: u2
        doc: Display/channel number within the regional guide.
      - id: program_data_count
        type: u4
        doc: Number of program-pointer entries belonging to this channel.
      - id: offset_to_program_pointer
        type: u4
        doc: 0x20-relative offset of this channel's program-pointer array.
    
    instances:
      pointer_to_program:
        pos: offset_to_program_pointer + 32
        type: pointer_to_program
        repeat: expr
        repeat-expr: program_data_count
        doc: Program IDs paired with pointers to their fixed program records.

  pointer_to_program:
    seq:
      - id: program_id
        type: u4
        doc: Program identifier used by the guide.
      - id: offset_to_program
        type: u4
        doc: 0x20-relative offset of the corresponding program_data_table.
        
    instances:
      pointer_to_program:
        pos: offset_to_program + 32
        type: program_data_table
        doc: Resolved program record.

  program_data_table:
    seq:
      - id: start_timestamp
        type: u4
        doc: Program start timestamp.
      - id: end_timestamp
        type: u4
        doc: Program end timestamp.
      - id: text_offset
        type: u4
        doc: 0x20-relative reference to program text in the companion string data.
      - id: genre
        type: u2
        doc: Genre code.
      - id: audio_type
        type: u2
        doc: Audio-type code.
      - id: resolution
        type: u4
        doc: Resolution/service code.
      - id: position
        type: u4
        doc: Program position/order field.
        
  unknown_table:
    seq:
      - id: start_timestamp
        type: u4
        doc: Start timestamp of this auxiliary interval.
      - id: end_timestamp
        type: u4
        doc: End timestamp of this auxiliary interval.
      - id: unk1
        type: u4
        doc: Number of nested 16-byte auxiliary records.
      - id: unk2
        type: u4
        doc: 0x20-relative offset of the nested auxiliary-record array.
        
    instances:
      unk_table:
        pos: unk2 + 32
        type: another_unknown_table
        repeat: expr
        repeat-expr: unk1
        doc: Nested records belonging to this timed auxiliary entry.
        
  another_unknown_table:
    seq:
      - id: unkw
        type: u4
      - id: unk
        type: u4
      - id: unk1
        type: u4
      - id: unk2
        type: u4
    
  pointer_table:
    seq:
      - id: value
        type: u4
        doc: 0x20-relative target offset.
        
    instances:
      target:
        pos: value + 32
        type: u4
        doc: Resolved 32-bit value at value + 0x20.
        
enums:
  broadcast_type:
    2: satellite_digital
    9: terrestrial_digital
    18: satellite_analog
    25: terrestrial_analog
