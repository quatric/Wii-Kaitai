meta:
  id: arte_tex
  title: ArtePiazza Nintendo DS texture container (.tex)
  file-extension: tex
  endian: le
doc: |
  ArtePiazza's Nintendo DS texture container. It is a small fixed header, a
  raw pixel block and a 16-bit RGB555 palette. There are two header
  variants, told apart only by their leading ASCII tag:

  * `TextureObject\0` -- 14-byte tag, a 0x70-byte-or-larger header, width and
    height stored as shift counts at `0x24`/`0x28`.
  * `TextureData\0` / `Texture Data\0` -- 12/13-byte tag, 56-byte-or-larger
    header, whose palette offset is relative to the end of the header.

  Texture formats are the DS GX ones, numbered as nintoolbox numbers them:
  1 = A3I5, 3 = 4 bpp indexed (low nibble first), 4 = 8 bpp indexed,
  6 = A5I3. Palette colours are RGB555 (`r = c & 0x1f`, `g = (c >> 5) & 0x1f`,
  `b = (c >> 10) & 0x1f`). For formats 3 and 4 palette index 0 is the
  transparent key.

  Width is `8 << width_shift` (for the `TextureData` variant, a shift above 8 is
  read as `shift * 4` pixels). Height is not stored directly: it is
  `pixel_bytes / width` (`* 2` for 4 bpp), falling back to `8 << height_shift`
  when that is zero.
seq:
  - id: tag
    size: 14
    doc: |
      Leading tag. The first byte is `T` in both variants; the
      `TextureObject\0` variant has `Object` after `Texture`, the other has
      `Data` / ` Data`. 14 bytes covers the longest tag.
  - id: rest_of_header
    type: header_object
    if: is_object
    size: 0x62
  - id: rest_of_header_data
    type: header_data
    if: not is_object
    size: 0x2a
instances:
  is_object:
    value: tag[7] == 0x4f
    doc: "`TextureObject` has an `O` at index 7; `TextureData` has a `D`."
types:
  header_object:
    doc: Fields at file offsets 0x0e..0x6f of the `TextureObject` variant.
    seq:
      - id: pad_0e
        size: 18
        doc: Bytes 0x0e..0x1f, unused by the decoder.
      - id: format
        type: u4
        doc: Texture format (1, 3, 4 or 6).
      - id: width_shift
        type: u4
        doc: Width is `8 << width_shift`; must be <= 12.
      - id: height_shift
        type: u4
        doc: Fallback height is `8 << height_shift`; must be <= 12.
      - id: unknown_2c
        type: u4
      - id: pixel_bytes
        type: u4
        doc: Length of the pixel block.
      - id: pixel_offset
        type: u4
        doc: Absolute offset of the pixel block (the header length).
      - id: palette_bytes
        type: u4
        doc: Length of the palette in bytes (two bytes per colour).
      - id: palette_offset
        type: u4
        doc: Absolute offset of the palette; at least `pixel_offset`.
      - id: reserved
        size-eos: true
    instances:
      pixels:
        pos: pixel_offset
        size: pixel_bytes
        io: _root._io
      palette:
        pos: palette_offset
        size: palette_bytes
        io: _root._io
  header_data:
    doc: Fields at file offsets 0x0e..0x37 of the `TextureData` variant.
    seq:
      - id: pad_0e
        size: 2
      - id: format
        type: u4
        doc: Texture format (1, 3, 4 or 6), at file offset 0x10.
      - id: pixel_offset
        type: u4
        doc: Absolute offset of the pixel block (the header length), >= 56.
      - id: pad_18
        size: 12
      - id: width_shift
        type: u4
        doc: At file offset 0x24; values above 8 are read as `shift * 4` pixels.
      - id: height_shift
        type: u4
        doc: At file offset 0x28.
      - id: pixel_bytes
        type: u4
      - id: palette_offset_rel
        type: u4
        doc: Palette offset relative to `pixel_offset`.
      - id: palette_bytes
        type: u4
    instances:
      pixels:
        pos: pixel_offset
        size: pixel_bytes
        io: _root._io
      palette:
        pos: pixel_offset + palette_offset_rel
        size: palette_bytes
        io: _root._io
