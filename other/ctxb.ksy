meta:
  id: ctxb
  file-extension: ctxb
  endian: le
  title: Grezzo 3DS CTXB texture container
doc: |
  CTXB is the container `SaveCTXB()` in nintoolbox's lib-ctxb.c writes when
  exporting a decoded image back to a 3DS-style texture file: a small
  header pointing at one `tex ` chunk, which holds a table of texture
  entries whose pixel data (Pica200-tiled RGBA8, per `DecodePicaTexture`-
  style 8x8 Z-order blocks) follows immediately after the chunk.

  This file only ever *writes* one chunk with one texture entry, so the
  struct below generalizes the writer's fixed layout (chunk_count and
  tex_count as counted fields) rather than being derived from a reader --
  there is no `ScanCTXB`/`LoadCTXB` in this codebase to check field-by-field
  against real-world multi-entry files.
seq:
  - id: magic
    contents: "ctxb"
  - id: file_size
    type: u4
  - id: chunk_count
    type: u4
    doc: Number of chunks following the header; always 1 from this writer.
  - id: reserved
    type: u4
  - id: chunk_offset
    type: u4
    doc: File-relative offset of the first (only) chunk.
  - id: tex_data_offset
    type: u4
    doc: File-relative offset where raw texture pixel data begins.
instances:
  chunk:
    pos: chunk_offset
    type: tex_chunk
types:
  tex_chunk:
    seq:
      - id: magic
        contents: "tex "
      - id: section_size
        type: u4
        doc: Size of this chunk's entry table (36 bytes per entry from this writer).
      - id: tex_count
        type: u4
      - id: entries
        type: tex_entry
        repeat: expr
        repeat-expr: tex_count
  tex_entry:
    seq:
      - id: data_size
        type: u4
      - id: unknown1
        type: u2
      - id: unknown2
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format
        type: u4
        doc: Pica200 texture format; the writer always emits 0x14016752 (RGBA8).
      - id: data_rel_offset
        type: u4
        doc: Offset of this entry's pixel data relative to the container's tex_data_offset.
      - id: name
        size: 16
        type: strz
        encoding: ASCII
        doc: Texture name, truncated to 15 characters plus NUL by the writer.
    instances:
      body:
        io: _root._io
        pos: _root.tex_data_offset + data_rel_offset
        size: data_size
