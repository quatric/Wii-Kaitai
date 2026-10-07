meta:
  id: jade_bigfile
  title: Ubisoft Jade BigFile (.bf)
  file-extension: bf
  endian: le
doc: |
  Ubisoft's Jade/LyN-engine BigFile (`BIG\0`): Beyond Good & Evil, Rayman Raving
  Rabbids 1/2/TV Party, Prince of Persia (Wii), Petz, TMNT, Rabbids Go Home,
  My Word Coach, ... Layout follows the public Ray1Map reverse engineering and
  is verified against Wii retail files (little-endian, version 44).

  This definition covers the plain `BIG\0` form. Two variants need pre-processing
  that Kaitai cannot express here:

  * `BUG\0` files XOR the header fields and the FAT blocks with the 4-byte key
    `b3 98 cc 66`, indexed by absolute file offset modulo 4; payloads are not XORed.
    The universe key at 0x28 is not XORed.
  * Some platforms are big-endian. nintoolbox tries little-endian first and
    falls back to big-endian when the version is outside 30..80.

  After the header come `num_fat` FAT blocks, each:

      0x18-byte header {max_file, max_dir, pos_fat, next_pos_fat, first_index, last_index}
      size_of_fat * 8       file refs   {offset, key}
      size_of_fat * N       file infos
      size_of_fat * 0x54    directory infos

  with `N` = 0x54 for versions 34/37/38, 0x7C for version >= 42 and 0x58
  otherwise. Only the first `max_file`/`max_dir` slots of each array are filled.
  File payloads sit at their offset as `u4 size` (low 31 bits) followed by the data.
  Members are extracted as stored; no decompression is attempted.
seq:
  - id: magic
    contents: ['BIG', 0]
  - id: version
    type: u4
    doc: 30..80; 44 on Wii retail files.
  - id: max_file
    type: u4
  - id: max_dir
    type: u4
  - id: max_key
    type: u4
  - id: root
    type: u4
  - id: first_free_file
    type: s4
  - id: first_free_dir
    type: s4
  - id: size_of_fat
    type: u4
    doc: Slots per FAT block.
  - id: num_fat
    type: u4
  - id: universe_key
    type: u4
  - id: engine_keys
    size: 44
    if: version >= 43
    doc: A u4 plus ten u4 keys.
  - id: fats
    type: fat_block
    repeat: expr
    repeat-expr: num_fat
types:
  fat_block:
    seq:
      - id: max_file
        type: u4
        doc: Number of used file slots in this block.
      - id: max_dir
        type: u4
        doc: Number of used directory slots in this block.
      - id: pos_fat
        type: u4
      - id: next_pos_fat
        type: u4
      - id: first_index
        type: u4
      - id: last_index
        type: u4
      - id: file_refs
        type: file_ref
        repeat: expr
        repeat-expr: _root.size_of_fat
      - id: file_infos
        type: file_info
        repeat: expr
        repeat-expr: _root.size_of_fat
      - id: dir_infos
        type: dir_info
        repeat: expr
        repeat-expr: _root.size_of_fat
  file_ref:
    seq:
      - id: offset
        type: u4
        doc: Absolute offset of the payload; 0 / 0xffffffff means unused.
      - id: key
        type: u4
    instances:
      payload_size:
        pos: offset
        type: u4
        io: _root._io
        if: offset != 0 and offset != 0xffffffff
        doc: Low 31 bits are the payload length; the data follows.
  file_info:
    seq:
      - id: length
        type: u4
      - id: prev
        type: s4
      - id: next
        type: s4
      - id: parent_dir
        type: s4
      - id: date
        type: u4
      - id: name
        type: strz
        size: 0x40
        encoding: ASCII
      - id: p4_revision
        type: u4
        if: _root.version != 34 and _root.version != 37 and _root.version != 38
      - id: hash
        size: 0x20
        if: _root.version >= 42
      - id: hash_tail
        type: u4
        if: _root.version >= 42
  dir_info:
    seq:
      - id: first_file
        type: s4
      - id: first_sub
        type: s4
      - id: prev
        type: s4
      - id: next
        type: s4
      - id: parent
        type: s4
      - id: name
        type: strz
        size: 0x40
        encoding: ASCII
