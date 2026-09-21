meta:
  id: bti
  file-extension: bti
  endian: be
  title: Nintendo GameCube/Wii BTI texture
doc: |
  A single GX texture in Nintendo's "Binary Texture Image" container, used
  standalone (`.bti`) and embedded inside BMD/BDL models and other GC/Wii
  formats. Unlike NW4R's TEX0, a BTI can carry its own palette.

  Field layout taken from `bti_header_t` in lib-image.h, whose own comment
  attributes the unknown-field names to http://www.amnoid.de/gc/bti.txt.
  `n_image` counts the base image plus mipmaps; `pal_off`/`data_off` are
  both relative to the start of this header (offset 0), per lib-image.c's
  `SaveBTI()`/`SetupPointerBTI()`.
seq:
  - id: iform
    type: u1
    enum: image_format
    doc: GX texture format of the image data.
  - id: unknown_01
    type: u1
    doc: '0x02 for `posteffect.bti`-style textures, 0x00 otherwise.'
  - id: width
    type: u2
  - id: height
    type: u2
  - id: wrap_s
    type: u1
  - id: wrap_t
    type: u1
  - id: pform
    type: u2
    enum: palette_format
    doc: GX palette format; only meaningful when `iform` is colour-indexed.
  - id: n_pal
    type: u2
    doc: Number of palette entries; 0 when there is no palette.
  - id: pal_off
    type: u4
    doc: Offset of the palette data, relative to the start of this header.
  - id: unknown_10
    type: u4
  - id: unknown_14
    type: u1
  - id: unknown_15
    type: u1
  - id: unknown_16
    type: u2
  - id: n_image
    type: u1
    doc: Number of images stored (base image + mipmaps).
  - id: unknown_19
    type: u1
  - id: unknown_1a
    type: u2
  - id: data_off
    type: u4
    doc: Offset of the base image's texel data, relative to the start of this header.
instances:
  palette:
    pos: pal_off
    size: n_pal * 2
    if: pal_off != 0 and n_pal != 0
    doc: Raw palette entries (2 bytes each, in `pform`); not decoded here.
  image_data:
    pos: data_off
    size-eos: true
    doc: |
      Raw GX texel blocks for the base image, followed immediately by each
      mipmap (each level halving, block-padded per `iform`). Not decoded
      here -- block layout is format-specific.
enums:
  image_format:
    0x0: i4
    0x1: i8
    0x2: ia4
    0x3: ia8
    0x4: rgb565
    0x5: rgb5a3
    0x6: rgba8
    0x8: c4
    0x9: c8
    0xa: c14x2
    0xe: cmpr
  palette_format:
    0: ia8
    1: rgb565
    2: rgb5a3
