meta:
  id: bfsar
  file-extension: bfsar
  title: NintendoWare BFSAR/BCSAR sound archive
doc: |
  Wii U / Switch / 3DS Sound Archive ("FSAR"/"CSAR" magic; the RSAR/BRSAR
  family's successor generation, a different byte format despite the
  similar purpose). Layout follows the Citric Composer project's written
  spec for the generic block-table container plus STRG (string table
  and binary-trie name lookup); the INFO block's real Sound/Bank/Player/
  WaveArchive/SoundGroup/Group/File directory has a documented but far
  more involved per-record layout that this tool's own reader treats as
  future work beyond the directory-location/basics covered here (see
  lib-bfsar.h's scope note), so it is kept as a raw block below. The
  FILE block is a plain payload pool addressed from INFO's File entries
  by (pool-relative offset, size) and is likewise left opaque.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: '"FSAR" (Wii U/Switch) or "CSAR" (3DS).'
  - id: bom
    type: u2be
    doc: 0xfeff for big-endian content, 0xfffe for little-endian.
  - id: content
    type:
      switch-on: bom
      cases:
        0xfeff: body(false)
        0xfffe: body(true)
types:
  body:
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
      - id: version
        type: u4
        doc: |
          Packed version, byte order per family: 0x00MMIIRR for
          FSAR-type files, 0xMMIIRR00 for CSAR-type files.
      - id: len_file
        type: u4
      - id: len_header
        type: u2
      - id: num_blocks
        type: u2
      - id: block_refs
        type: block_ref
        repeat: expr
        repeat-expr: num_blocks
    types:
      block_ref:
        seq:
          - id: block_type
            type: u4
          - id: ofs_block
            type: u4
            doc: Absolute file offset of the referenced block.
          - id: len_block
            type: u4
        instances:
          block:
            io: _root._io
            pos: ofs_block
            size: len_block
            type:
              switch-on: block_type
              cases:
                0x2000: strg_block
                0x2001: raw_block
                0x2002: raw_block
      raw_block:
        doc: INFO (0x2001) or FILE (0x2002) block; not modeled further, see the format doc above.
        seq:
          - id: magic
            type: str
            size: 4
            encoding: ASCII
          - id: len_self
            type: u4
          - id: body
            size-eos: true
      strg_block:
        seq:
          - id: magic
            contents: "STRG"
          - id: len_self
            type: u4
          - id: ref0
            size: 4
          - id: ref_string_table
            type: sized_ref
          - id: ref1
            size: 4
          - id: ref_lookup_table
            type: sized_ref
        instances:
          string_table:
            io: _root._io
            pos: _parent.ofs_block + ref_string_table.ofs + 8
            type: string_table
            if: ref_string_table.ofs != -1
          lookup_table:
            io: _root._io
            pos: _parent.ofs_block + ref_lookup_table.ofs + 8
            type: lookup_table
            if: ref_lookup_table.ofs != -1
      sized_ref:
        doc: A "Reference" per the Citric Composer spec -- a type tag plus a self-relative offset (-1 for "absent").
        seq:
          - id: ref_type
            type: u2
          - id: reserved
            type: u2
          - id: ofs
            type: s4
      string_table:
        seq:
          - id: num_strings
            type: u4
          - id: entries
            type: string_entry
            repeat: expr
            repeat-expr: num_strings
      string_entry:
        seq:
          - id: unknown0
            type: u4
          - id: ofs_string
            type: s4
            doc: Relative to the STRG block's own start, plus a fixed +24 this tool's reader confirmed against real files.
          - id: len_string
            type: u4
            doc: Includes the trailing NUL.
        instances:
          string:
            io: _root._io
            pos: _parent._parent._parent.ofs_block + ofs_string + 24
            type: strz
            encoding: UTF-8
            if: len_string > 0
      lookup_table:
        doc: A binary-trie (Patricia trie) node table mapping an id to a string-table index.
        seq:
          - id: unknown0
            type: u4
          - id: num_nodes
            type: u4
          - id: nodes
            type: lookup_node
            repeat: expr
            repeat-expr: num_nodes
      lookup_node:
        seq:
          - id: is_leaf
            type: u2
          - id: bit_index
            type: u2
          - id: idx_left
            type: u2
          - id: idx_right
            type: u2
          - id: string_index
            type: u4
          - id: id
            type: u4
            doc: Only meaningful when `is_leaf != 0`.
