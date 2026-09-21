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
    type: outer_chunk
    doc: >-
      The top-level model chunk.  Its bounded payload is parsed into inner
      chunks rather than left as an opaque byte blob.
types:
  outer_chunk:
    seq:
      - id: tag
        type: u4
        doc: >-
          Outer tag (normally 0x8001b000 or 0x8001b001 for a model; the
          nearby 0x8001b100 family denotes a map container).
      - id: length
        type: u4
        doc: Byte length of the complete inner-chunk run that follows.
      - id: payload
        type: inner_chunk_stream
        size: length
        doc: Inner chunks, bounded exactly by the outer length.
    instances:
      key:
        value: tag & 0xffffff
        doc: Low 24-bit top-level container key.
      has_children:
        value: (tag >> 24) & 1 != 0
        doc: Tag bit 24, set for a container whose payload is chunked.
  inner_chunk_stream:
    seq:
      - id: chunks
        type: chunk
        repeat: eos
        doc: >-
          Back-to-back GameCube inner chunks.  Wii RLG files align each
          section to four bytes and are intentionally not parsed by this
          unpadded GLG stream type.
  chunk:
    seq:
      - id: tag
        type: u4
        doc: >-
          Chunk tag: top bit is set and low 24 bits identify the role.  Bits
          24..30 carry producer alignment metadata; GameCube GLG does not
          insert padding between chunks.
      - id: length
        type: u4
        doc: Exact payload byte length, excluding the 8-byte chunk header.
      - id: payload
        size: length
        doc: >-
          Raw payload.  Its shape is selected by key (for example VAPD
          records for 0x1b005 or u16 indices for 0x1b007); those payloads
          remain raw here because their role depends on sibling chunks.
    instances:
      key:
        value: tag & 0xffffff
        doc: >-
          24-bit role ID: 0x1b001 flags, 0x1b002 root matrix, 0x1b003 model
          table, 0x1b004 mesh table, 0x1b005 VAPD, 0x1b006 vertices, or
          0x1b007 indices in geometry-only files.
      has_children:
        value: (tag >> 24) & 1 != 0
        doc: Tag bit 24, retained for containers outside the basic GLG model set.
  vapd_entry:
    seq:
      - id: reserved
        type: u2
        doc: Reserved VAPD word.
      - id: byte_offset
        type: u2
        doc: Byte offset into the 0x1b006 vertex chunk.
      - id: attr_index
        type: u1
        doc: Attribute-set/index selector.
      - id: attr_type
        type: u1
        doc: >-
          Attribute kind: 0 = position, 1 = normal, 3 = texture coordinate
          in the GameCube files handled by nintoolbox.
  model_entry:
    seq:
      - id: mesh_count
        type: u4
        doc: Number of mesh records attached to this model-table entry.
      - id: hash
        type: u4
        doc: Model identifier/hash.
      - id: padding
        size: 8
        doc: Unattributed model-table bytes; encoder writes zeros.
