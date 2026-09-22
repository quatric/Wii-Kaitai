meta:
  id: smashpac
  title: Super Smash Bros. 4 animation container (.pac)
doc: |
  Animation container used for .omo skeletal and .mta material animations,
  described by nintoolbox lib-smashpac.c. PACK uses little-endian integers;
  KCAP uses big-endian integers. This is unrelated to the Nd Cube PAC\0,
  HAL ARC\0, and Mario Kart Arcade PAC containers.

  The 16-byte header is followed by three parallel, count-element u32 tables:
  absolute name offsets, absolute payload offsets, and payload byte lengths.
  Table index, not file order, associates each name with its payload. Names
  are NUL-terminated. Payloads are opaque here; their extensions identify
  the nested animation format.

  nintoolbox accepts at most 100000 entries, requires all three tables to fit,
  a terminating NUL for every name, and every payload range to fit the file.
  Its writer emits both reserved words as zero, places names immediately after
  the tables, then aligns each payload start to a 16-byte boundary. Alignment
  and name placement describe writer output, not requirements of the reader.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    doc: PACK selects little-endian tables; KCAP selects big-endian tables.
  - id: content
    type: content_t(magic == "PACK")
types:
  content_t:
    params:
      - id: is_little_endian
        type: b1
    meta:
      endian:
        switch-on: is_little_endian
        cases:
          true: le
          false: be
    seq:
      - id: reserved_04
        type: u4
        doc: Unknown header word; nintoolbox writes zero.
      - id: num_entries
        type: u4
        valid:
          max: 100000
        doc: Number of elements in each of the three parallel tables.
      - id: reserved_0c
        type: u4
        doc: Unknown header word; nintoolbox writes zero.
      - id: name_offsets
        type: u4
        repeat: expr
        repeat-expr: num_entries
        doc: Absolute offsets to NUL-terminated member names.
      - id: data_offsets
        type: u4
        repeat: expr
        repeat-expr: num_entries
        doc: Absolute member payload offsets; writer aligns these to 16 bytes.
      - id: sizes
        type: u4
        repeat: expr
        repeat-expr: num_entries
        doc: Payload byte lengths, paired with offsets and names by table index.
      - id: entries
        type: member_t(name_offsets[_index], data_offsets[_index], sizes[_index])
        repeat: expr
        repeat-expr: num_entries
        doc: One logical member per table index; consumes no inline bytes.
    types:
      member_t:
        params:
          - id: name_offset
            type: u4
          - id: data_offset
            type: u4
          - id: data_size
            type: u4
        instances:
          name:
            type: str
            terminator: 0
            encoding: UTF-8
            pos: name_offset
            io: _root._io
            doc: Name resolved using its absolute offset; no fixed width.
          body:
            pos: data_offset
            size: data_size
            io: _root._io
            doc: Opaque payload, possibly zero-length.
