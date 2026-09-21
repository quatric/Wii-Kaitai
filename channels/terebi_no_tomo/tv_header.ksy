meta:
  id: header
  file-extension: .bin
  application: TV no Tomo
  endian: be
doc: >-
  TV no Tomo HDPK `001B` guide-header package.  Directory offsets throughout
  the file are relative to byte 0x20; every instance therefore resolves its
  stored offset with `+ 32`.  The file connects regions to channel selections
  and supplies lookup directories for genre, audio, resolution, bilingual,
  subtitle and copyright labels.

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
    doc: 0x20-relative common-pointer table offset.
  - id: pointer_table_size
    type: u4
    doc: Number of common pointer-table entries.
  - id: unknown
    type: u4
  - id: footer_size
    type: u4
    doc: Producer-declared footer length.
  - id: unknown1
    type: u4
  - id: unknown2
    type: u4
  - id: unknown3
    type: u4
  - id: unknown4
    type: u4
  - id: unknown5
    type: u4
  - id: unknown6
    type: u4
  - id: unknown7
    type: u4
  - id: unknown8
    type: u4
  - id: unknown9
    type: u4
  - id: header_size
    type: u4
    doc: Producer-declared size of the header/directory region.
  - id: unknown11
    type: u4
  - id: padding
    size: 12
  - id: number_of_channels
    type: u4
    doc: Number of 12-byte channel entries.
  - id: channel_table_offset
    type: u4
    doc: 0x20-relative channel-table offset.
  - id: number_of_regions
    type: u4
    doc: Number of 16-byte region entries.
  - id: region_table_offset
    type: u4
    doc: 0x20-relative region-table offset.
  - id: number_of_genres
    type: u4
    doc: Number of 8-byte genre entries.
  - id: genre_table_offset
    type: u4
    doc: 0x20-relative genre-table offset.
  - id: number_of_audio_types
    type: u4
    doc: Number of audio-type entries.
  - id: audio_type_table_offset
    type: u4
    doc: 0x20-relative audio-type table offset.
  - id: number_of_resolution_types
    type: u4
    doc: Number of resolution-type entries.
  - id: resolution_type_table_offset
    type: u4
    doc: 0x20-relative resolution-type table offset.
  - id: number_of_bilingual_tables
    type: u4
    doc: Number of bilingual-label entries.
  - id: bilingual_table_offset
    type: u4
    doc: 0x20-relative bilingual table offset.
  - id: number_of_unknown_tables
    type: u4
    doc: Despite being named unknown, it points to a text that translates to "subtitle"
  - id: unknown_table_offset
    type: u4
    doc: 0x20-relative subtitle-label table offset.
  - id: number_of_copyright_tables
    type: u4
    doc: Number of copyright-label entries (not yet structurally typed).
  - id: copyright_table_offset
    type: u4
    doc: 0x20-relative copyright-label table offset.
  - id: support_text_offset
    type: u4
    doc: 0x20-relative reference to support/help text.
    
instances:
  pointer_table:
    pos: pointer_table_offset + 32
    type: pointer_table
    repeat: expr
    repeat-expr: pointer_table_size
    doc: Common directory of 0x20-relative pointers.
    
  channel_table:
    pos: channel_table_offset + 32
    type: channel_table
    repeat: expr
    repeat-expr: number_of_channels
    doc: Channel lookup entries.
    
  region_table:
    pos: region_table_offset + 32
    type: region_table
    repeat: expr
    repeat-expr: number_of_regions
    doc: Region lookup entries with channel-selection lists.
    
  genre_table:
    pos: genre_table_offset + 32
    type: genre_table
    repeat: expr
    repeat-expr: number_of_genres
    doc: Genre lookup entries.
    
  audio_type_table:
    pos: audio_type_table_offset + 32
    type: audio_type_table
    repeat: expr
    repeat-expr: number_of_audio_types
    doc: Audio-type lookup entries.
    
  resolution_type_table:
    pos: resolution_type_table_offset + 32
    type: resolution_type_table
    repeat: expr
    repeat-expr: number_of_resolution_types
    doc: Resolution-type lookup entries.
    
  bilingual_table:
    pos: bilingual_table_offset + 32
    type: bilingual_table
    repeat: expr
    repeat-expr: number_of_bilingual_tables
    doc: Bilingual-label lookup entries.
    
  unknown_table:
    pos: unknown_table_offset + 32
    type: unknown_table
    repeat: expr
    repeat-expr: number_of_unknown_tables
    doc: Subtitle-label lookup entries.
    
types:
  pointer_table:
    seq:
      - id: value
        type: u4
        
    instances:
      target:
        pos: value + 32
        type: u4
  channel_table:
    seq:
      - id: broadcast_type
        type: u2
        enum: broadcast_type
      - id: id
        type: u2
        doc: this id corrsponds with the ID in channel selection table
      - id: text_offset
        type: u4
      - id: broadcast_type_again
        type: u1
        enum: broadcast_type
      - id: padding
        size: 3

  region_table:
    seq:
      - id: region_code
        type: u2
        doc: this code is what the channel uses to request the proper data
      - id: prefecture_array_position
        type: u1
      - id: padding
        type: u1
      - id: text_offset
        type: u4
      - id: number_of_channels
        type: u4
      - id: channel_selection_table_offset
        type: u4
    
    instances:
      channel_selection_table:
        pos: channel_selection_table_offset + 32
        type: channel_selection_table
        repeat: expr
        repeat-expr: number_of_channels
        
  channel_selection_table:
    seq: 
      - id: broadcast_type
        type: u2
        enum: broadcast_type
      - id: id
        type: u2
      - id: position
        type: u2
        doc: if 0, this channel is not autoselected
      - id: channel_number
        type: u2
      - id: is_autoselected
        type: u4
  
  genre_table:
    seq:
      - id: main_genre_pos
        type: u1
      - id: sub_genre_pos
        type: u1
      - id: padding
        type: u2
      - id: text_offset
        type: u4
        
  audio_type_table:  
    seq:
      - id: text_offset
        type: u4
      - id: id
        type: u2
      - id: padding
        type: u2
        
  resolution_type_table:  
    seq:
      - id: text_offset
        type: u4
      - id: id
        type: u4
        
  bilingual_table:
    seq:
      - id: text_offset
        type: u4
      - id: id
        type: u1
      - id: padding
        size: 3
        
  unknown_table:
    seq:
      - id: text_offset
        type: u4
      - id: id
        type: u1
      - id: padding
        size: 3
    
enums:
  broadcast_type:
    2: satellite_digital
    9: terrestrial_digital
    18: satellite_analog
    25: terrestrial_analog
