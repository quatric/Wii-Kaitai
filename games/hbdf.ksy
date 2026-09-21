meta:
  id: hbdf
  file-extension: hbdf
  endian: le
  title: DS HBDF/HSDF sysdolphin model
doc: |
  Nintendo DS "HBDF"/"HSDF" model container (ObjectBlock/MeshBlock Nitro GX
  display lists). An 8-byte header (magic + total file size) is followed by
  a flat sequence of tagged, self-sized chunks (MDLF, TEXS, ENVS, ANMF, ...).
  Only the "TEXS" chunk's own sub-block layout (image/palette info) is
  modeled further here; the geometry chunks are consumed by a dedicated
  Nitro GX display-list interpreter, not a fixed struct layout, and are
  left as raw chunk bytes. Ported from lib-hbdf.c's `ScanHBDF` and
  `hbdf_unpack_texs`.
seq:
  - id: magic
    contents: "HBDF"
    doc: Also seen as "HSDF"; both are accepted by the reader.
  - id: file_size
    type: u4
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: chunk_size
        type: u4
        doc: Size of this chunk, including the 8-byte tag/size header.
      - id: body
        size: chunk_size - 8
        type:
          switch-on: tag
          cases:
            '"TEXS"': texs_chunk
  texs_chunk:
    doc: Texture/palette info table embedded in a model's "TEXS" chunk.
    seq:
      - id: num_infos
        type: u2
      - id: num_images
        type: u2
      - id: num_palettes
        type: u2
      - id: reserved
        type: u2
      - id: sub_blocks
        type: texs_sub_block
        repeat: expr
        repeat-expr: num_infos.as<u4> + num_images.as<u4> + num_palettes.as<u4>
  texs_sub_block:
    doc: |
      One tagged sub-block of a TEXS chunk. Only "IMGO" (raw/LZ77-compressed
      image data) and "PLTO" (palette data) carry a name + payload; other
      tags are exposed only as raw bytes.
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: sub_size
        type: u4
      - id: body
        size: sub_size
