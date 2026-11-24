meta:
  id: umod_footer
  title: Unreal UMOD footer
  file-extension: umd
  endian: le
doc: |
  Open Season wiigame.umd. The directory is a compact-index entry count then
  entries; only the 20-byte footer is modelled.
seq:
  - id: body
    size: _io.size - 20
  - id: magic
    contents: [0xa3, 0xc5, 0xe3, 0x9f]
  - id: directory_offset
    type: u4
  - id: directory_size
    type: u4
  - id: version
    type: u4
  - id: crc
    type: u4
