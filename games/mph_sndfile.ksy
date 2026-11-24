meta:
  id: mph_sndfile
  title: Metroid Prime Hunters SNDFILE archive (.arc)
  file-extension: arc
  endian: be
doc: |
  After NoneGiven's MphRead. "SNDFILE\0", big-endian header: u32 file count, u32
  total size, 16 reserved bytes, then 64-byte records {char name[32], u32 offset,
  u32 padded size, u32 size, 20 reserved}; payloads 32-byte aligned. *_Model.bin
  files have no magic: 100-byte header, 240-byte nodes, 132-byte materials,
  4-byte meshes, 32-byte display-list records pointing at packed Nitro GX
  command streams, 40-byte texture and 16-byte palette records.
seq:
  - id: magic
    contents: ["SNDFILE", 0]
  - id: count
    type: u4
  - id: total_size
    type: u4
  - id: reserved
    size: 16
  - id: records
    type: record
    repeat: expr
    repeat-expr: count
types:
  record:
    seq:
      - id: name
        size: 32
        type: strz
        encoding: ASCII
      - id: offset
        type: u4
      - id: padded_size
        type: u4
      - id: size
        type: u4
      - id: reserved
        size: 20
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
