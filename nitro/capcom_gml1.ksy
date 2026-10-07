meta:
  id: capcom_gml1
  title: Capcom Ghost Trick GML1 script container (.xml.bin)
  file-extension: xml.bin
  endian: le
doc: |
  `1LMG` script binary of Ghost Trick: Phantom Detective (18 retail
  `.xml.bin` files, 929 inner `.xml.lz` files). A 48-byte header, then bytecode
  instructions, localized text blocks, and dictionary key-to-offset index
  tables. nintoolbox requires `data_length > 0`, `48 + data_length <= file
  size` and `key_offset >= 48`.
seq:
  - id: magic
    contents: '1LMG'
    doc: '`GML1` read backwards (little-endian `0x474D4C31`).'
  - id: flags
    type: u4
    doc: 0 for dialogue / database scripts, 102 for system menus.
  - id: data_length
    type: u4
    doc: Length of the data / bytecode section.
  - id: control_entry_count
    type: u4
  - id: key_table_offset
    type: u4
  - id: header_rest
    size: 48 - 0x14
  - id: data
    size: data_length
    doc: Bytecode, localized text blocks and index tables.
  - id: trailer
    size-eos: true
