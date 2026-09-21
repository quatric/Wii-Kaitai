meta:
  id: ajpg
  file-extension: ajpg
  endian: be
  title: ActImagine AJPG still image (ODH)
doc: |
  ActImagine/Nintendo's baseline-JPEG-derived still image format,
  originally for GBA, later used by the Wii Message Board for photo
  attachments. A fixed 16-byte header (magic plus one packed 32-bit
  field, the rest reserved) is followed directly by the entropy-coded
  DCT data; nothing in the header gives the coded data's length, so it
  runs to EOF.

  The packed field at header offset 4 (big-endian u4) holds, from the
  low bit upward: width (11 bits), height (11 bits), horizontal chroma
  subsampling flag (1 bit), vertical chroma subsampling flag (1 bit),
  quality (8 bits, top byte).
seq:
  - id: magic
    contents: "AJPG"
  - id: packed_dims
    type: u4
  - id: reserved
    size: 8
    doc: Unused/reserved header tail; header is a fixed 16 bytes.
  - id: coded_data
    size-eos: true
    doc: Huffman/DCT-coded pixel data; length is not stored, so this runs to EOF.
instances:
  width:
    value: packed_dims & 0x7ff
  height:
    value: (packed_dims >> 11) & 0x7ff
  chroma_subsample_x:
    value: (packed_dims >> 22) & 1
  chroma_subsample_y:
    value: (packed_dims >> 23) & 1
  quality:
    value: (packed_dims >> 24) & 0xff
