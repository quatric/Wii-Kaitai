meta:
  id: glg
  file-extension: glg
  endian: be
  title: Next Level Games GLG model (Super Mario Strikers, GameCube)
doc: |
  Big-endian chunked container reverse engineered from the retail asset
  corpus and the GameCube runtime loader (decompiled in Ghidra), ported
  from nintoolbox's `lib-glg.h`/`lib-glg.c`.

  The whole file is one outer chunk whose tag's low bits identify it as
  the top-level model container (`0x8001b000` or `0x8001b001`; a map
  container instead uses `0x8001b100` and is not modeled here). Its
  payload is a flat run of inner chunks, each `{ tag, length, payload }`,
  consumed back to back until `length` bytes of the outer chunk are used.

  A tag's top bit is always set; the low 24 bits are the "key" that
  identifies the chunk's role (see `key` below). Known keys for a
  geometry-only file:

  - `0x1b001` (4 bytes): opaque version/flags, preserved verbatim.
  - `0x1b002` (64 bytes): 4x4 float root transform matrix.
  - `0x1b003`: model table, 16 bytes/entry (mesh count, hash, 8 bytes pad).
  - `0x1b004`: mesh table, 0x4a (74) bytes/entry.
  - `0x1b005`: vertex-attribute descriptors (VAPD), 6 bytes/entry.
  - `0x1b006`: packed vertex attribute arrays, back to back at VAPD-declared offsets.
  - `0x1b007`: flat u16 index array.
seq:
  - id: outer
    type: chunk
types:
  chunk:
    seq:
      - id: tag
        type: u4
        doc: Top bit set; low 24 bits are the chunk `key`.
      - id: length
        type: u4
      - id: payload
        size: length
    instances:
      key:
        value: tag & 0xffffff
      has_children:
        value: (tag >> 24) & 1 != 0
  vapd_entry:
    seq:
      - id: reserved
        type: u2
      - id: byte_offset
        type: u2
        doc: Byte offset into the 0x1b006 vertex chunk.
      - id: attr_index
        type: u1
      - id: attr_type
        type: u1
  model_entry:
    seq:
      - id: mesh_count
        type: u4
      - id: hash
        type: u4
      - id: padding
        size: 8
