meta:
  id: btf_bundle
  title: Famicom Wars VS texture/font bundle (.btf)
  file-extension: btf
  endian: le
doc: |
  Totsugeki!! Famicom Wars VS (Wii) `*.btf`. Files without the `FTBG` magic
  (ObjButton_*, some fonts) are not decoded by nintoolbox. The chunk header is
  little endian; the chunk body is big endian (`chunk_body`). The GX-tiled
  pixel data are the last `width * height * bpp` bytes of the chunk.
seq:
  - id: magic
    contents: FTBG
  - id: len_file
    type: u4
  - id: num_chunks
    type: u4
  - id: chunks
    type: chunk
    repeat: expr
    repeat-expr: num_chunks
types:
  chunk:
    seq:
      - id: tag
        contents: DXTG
      - id: len_chunk
        type: u4
      - id: body
        size: len_chunk
        type: chunk_body
  chunk_body:
    meta:
      endian: be
    seq:
      - id: name
        size: 0x20
        type: strz
        encoding: ASCII
      - id: width
        type: u4
      - id: height
        type: u4
      - id: one
        type: u4
      - id: id
        type: u4
      - id: format
        size: 8
        type: str
        encoding: ASCII
        doc: 'Reversed text right-aligned: "A8R8G8B8", "I8", "IA4", "P4", "P8".'
      - id: palette_format
        size: 8
        type: str
        encoding: ASCII
      - id: rest
        size-eos: true
        doc: '`PAL ` block (u32 size, palette from +12 as GX RGB5A3), `PIM ` block, pixels.'
