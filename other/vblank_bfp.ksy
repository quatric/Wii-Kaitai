meta:
  id: vblank_bfp
  endian: le
  title: Vblank Entertainment Wii game data package (BFP2)
doc: |
  Vblank Entertainment "gamedata_wii.bfp" package (Retro City
  Rampage DX, Shakedown: Hawaii), per lib-vblank.h. A member is
  stored raw when size == stored_size, else zlib-compressed. The
  sibling BPP3/BAP1 audio package variants documented in the same
  header are not modeled here.
seq:
  - id: magic
    contents: "BFP2"
  - id: num_named
    type: u4
    doc: '<= 192.'
  - id: unknown_08
    size: 0x40 - 8
  - id: named_entries
    type: named_entry_t
    repeat: expr
    repeat-expr: num_named
  - id: numbered_entries
    type: numbered_entry_t
    repeat: expr
    repeat-expr: 256
types:
  named_entry_t:
    seq:
      - id: name_hash
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: stored_size
        type: u4
    instances:
      body:
        pos: offset
        size: stored_size
        io: _root._io
        if: offset != 0
  numbered_entry_t:
    doc: offset == 0 means this numbered slot is empty.
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: stored_size
        type: u4
    instances:
      body:
        pos: offset
        size: stored_size
        io: _root._io
        if: offset != 0
