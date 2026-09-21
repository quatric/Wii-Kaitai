meta:
  id: dc2_dct
  file-extension: dct
  endian: be
  title: DC2 engine texture (Jakers! Kart Racing, Wii)
doc: |
  Wii GX texture format used by the DC2 engine (Jakers! Kart Racing).
  Tagged `DC2\0`, but every multi-byte field after the tag sits at an
  offset one byte higher than its nominal 4-byte alignment would suggest
  -- the whole header is effectively built starting at byte offset 3, so
  fields land at `0x1b`, `0x1f`, `0x23`, and so on (4k+3) rather than at
  round 4-byte boundaries. This structure keeps those exact literal
  offsets rather than re-deriving them, matching `lib-dc2.c`.

  `width`/`height` are stored twice (once at `0x1b`/`0x1f`, again at
  `0x23`/`0x27`) and both copies must agree for the texture to be
  considered valid. The top mip's byte size at `0x3a` doubles as the
  format selector: if it matches the CMPR-tiled size for `width`/`height`
  the image is 4-bit CMPR (Wii GX format 14); if it matches the RGBA8
  size instead, it is 32bpp RGBA8 (format 6). Smaller mip levels and a
  variable-length (~28..140 byte) serialised texture-sampler trailer
  follow the top mip's image data and are not modeled here. Animated
  textures stack several full frames back to back after the first; only
  the first is exposed as `image` since only it is decoded by
  `lib-dc2.c`.
seq:
  - id: magic
    contents: [0x44, 0x43, 0x32, 0x00]
    doc: Literal bytes "DC2\0".
  - id: pad
    size: 0x1b - 4
    doc: Unmodeled leader bytes before the field block; not walked by the decoder.
  - id: width
    type: u4
  - id: height
    type: u4
  - id: width2
    type: u4
    doc: Second copy of `width`; must equal it for the texture to be accepted.
  - id: height2
    type: u4
    doc: Second copy of `height`; must equal it for the texture to be accepted.
  - id: num_mips
    type: u4
    doc: Mip level count, 1..16.
  - id: pad2
    size: 0x3a - 0x2f
    doc: |
      Wrap/filter sampler bytes at 0x33.. plus unmodeled padding; not
      decoded by `lib-dc2.c` beyond being skipped.
  - id: len_top_mip
    type: u4
    doc: |
      Byte size of the top mip level's image data. Doubles as the format
      selector: equals the CMPR-tiled size for `width`x`height` when the
      image is CMPR, or the RGBA8-tiled size when it is RGBA8.
  - id: image
    size: len_top_mip
    doc: |
      Top mip level, Wii GX tiled: CMPR when `len_top_mip` matches the 4
      bits-per-pixel CMPR size, RGBA8 (32 bits per pixel) otherwise.
      Smaller mips, the sampler trailer, and any stacked animation frames
      follow and are not covered by this structure.
