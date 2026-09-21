meta:
  id: sarc
  file-extension:
    - sarc
    - arc
  endian: be
  title: Nintendo SARC archive
doc: |
  The plain archive Nintendo shipped from the 3DS and Wii U onward: a
  header, a file-allocation table, a string table, then the payloads. No
  compression of its own -- a compressed archive is a SARC wrapped in Yaz0
  or ZSTD, unwrapped before it reaches this structure.

  Endianness is per-file, not per-console. The byte-order mark at offset 6
  decides it and the whole file follows: the Swapdoodle samples are
  little-endian 3DS archives, while Wii U ones are typically big-endian.

  That mark is why the real structure sits in `content` rather than at the
  top level. Kaitai can compute a type's endianness from an expression,
  but the expression has to be settled before the type is read, and a
  positional instance of the same type is not -- the Python target
  compiles every such instance behind a test on the very flag it would be
  deciding. Reading the mark in a plain outer type and passing the answer
  down as a parameter avoids that. Everything that has to follow the
  computed order is nested inside `archive`, because a type declared
  alongside it would silently inherit this file's default instead.

  SARC itself is not tied to either console SDK generation the way the
  formats it typically carries are -- it is a plain filesystem-style
  archive used across both the 3DS's NW4C tooling and the Wii U's NW4F
  tooling (and by non-NintendoWare Nintendo titles besides), which is why
  it can hold either generation's payloads: the Swapdoodle corpus this
  definition was checked against is entirely NW4C-era `.bflyt`/`.bflan`.

  Names are optional. A node stores a hash of its path either way, so the
  runtime can look a file up without the string table present, and the top
  byte of `attributes` says whether a name was kept as well. Every file in
  the samples has one, since they were built from a directory tree with
  paths like `blyt/Common.bflyt`.
instances:
  bom:
    pos: 6
    type: u2be
    doc: |
      Read as raw big-endian bytes before any endianness is settled:
      0xfeff means the file is big-endian, 0xfffe little-endian.
  content:
    pos: 0
    type: archive(bom == 0xfffe)
    doc: The archive proper, read back from offset 0 in the decided order.
types:
  archive:
    params:
      - id: is_le
        type: bool
    meta:
      endian:
        switch-on: is_le
        cases:
          true: le
          false: be
    seq:
      - id: magic
        contents: "SARC"
      - id: len_header
        type: u2
        doc: 0x14.
      - id: bom
        type: u2
        doc: |
          The same mark, now read in the settled order, so it always comes
          back 0xfeff.
      - id: len_file
        type: u4
        doc: Total archive size, matching the real file length in all samples.
      - id: ofs_data
        type: u4
        doc: |
          Start of the payload region. Every node's `ofs_begin` and
          `ofs_end` are relative to this, not to the file.
      - id: version
        type: u2
        doc: 0x0100.
      - id: reserved
        type: u2
      - id: fat
        type: file_allocation_table
      - id: fnt
        type: file_name_table
        size: 'ofs_data - (len_header + fat.len_header + fat.num_nodes * 16)'
        doc: |
          The name table has no length of its own; it runs from where the
          node array ends to the start of the payload region.
    types:
      file_allocation_table:
        doc: |
          `SFAT`. Nodes are sorted by `name_hash`, which is what lets a
          runtime holding only a path hash find a file by binary search.
        seq:
          - id: magic
            contents: "SFAT"
          - id: len_header
            type: u2
            doc: 0x0c.
          - id: num_nodes
            type: u2
          - id: hash_key
            type: u4
            doc: |
              Multiplier for the path hash: from a zero seed, each byte of
              the full relative path gives `hash = hash * hash_key + byte`
              as u32. 0x65 throughout the samples, and confirmed by
              recomputing it for every member file in them.
          - id: nodes
            type: node
            repeat: expr
            repeat-expr: num_nodes

      node:
        seq:
          - id: name_hash
            type: u4
          - id: attributes
            type: u4
          - id: ofs_begin
            type: u4
          - id: ofs_end
            type: u4
            doc: |
              Both relative to the archive's `ofs_data`. `ofs_end` is
              exclusive, so a file's length is the difference -- there is
              no separate size field.
        instances:
          has_name:
            value: (attributes >> 24) != 0
          ofs_name:
            value: (attributes & 0xffffff) * 4
            doc: |
              Offset into the string table, stored divided by four because
              the names there are padded to a four-byte boundary.
          name:
            io: _parent._parent.fnt._io
            pos: ofs_name + 8
            type: strz
            encoding: ASCII
            if: has_name
            doc: |
              A full relative path, e.g. `blyt/Common.bflyt`. The `+ 8`
              steps over the `SFNT` tag and its header fields, since
              `ofs_name` counts from the first string.
          body:
            io: _root._io
            pos: _parent._parent.ofs_data + ofs_begin
            size: ofs_end - ofs_begin

      file_name_table:
        doc: |
          `SFNT`, immediately followed by the NUL-terminated names. It
          carries no count -- the nodes index into it.
        seq:
          - id: magic
            contents: "SFNT"
          - id: len_header
            type: u2
            doc: 0x08.
          - id: reserved
            type: u2
          - id: names
            size-eos: true
            doc: The raw string blob; `node.name` indexes into this substream.
