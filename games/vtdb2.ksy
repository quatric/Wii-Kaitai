meta:
  id: vtdb2
  title: VoiceText TTS database (.vtdb2)
  file-extension: vtdb2
  endian: le
doc: |
  Tomodachi Life: Living the Dream. Names and ".txt2" word lists are stored
  with every byte + `key`. Members follow the table back to back to EOF.
seq:
  - id: count
    type: u4
  - id: name_size
    type: u4
    doc: 0x200.
  - id: key
    type: u4
    doc: 10.
  - id: info
    size: name_size
    doc: '"3 12 3 0 0 <voice> <voice>-D32-FileIO".'
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name
        size: _root.name_size
        doc: Build-machine path, bytes shifted by key.
      - id: source
        size: _root.name_size
      - id: offset
        type: u4
      - id: size
        type: u4
