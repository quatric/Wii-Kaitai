meta:
  id: tex0
  file-extension: tex0
  endian: be
  imports:
    - brres_sub_header
  title: NW4R TEX0 texture
doc: |
  A single GX texture as stored in a BRRES `Textures(NW4R)` folder, or
  extracted to a standalone file.

  TEX0 holds nothing but the raw GX texel blocks -- there is no palette
  here even when the format is a colour-indexed one. Indexed textures name
  a PLT0 of the same name in the container's `Palettes(NW4R)` folder, which
  is why `has_palette` and a `CI*` `format` always agree: in every sample
  checked, `format` being CI4/CI8/CI14X2 and `has_palette` being 1 were the
  same condition.

  A TEX0 is not linked to the material that uses it by pointer either: an
  MDL0 material's texture layer (`texture_ref` in `mdl0.ksy`) names the
  TEX0 it samples, the same by-name convention TEX0/PLT0 use between
  themselves. This is consistent with BrawlBox/Tockdom's description of
  the format, where textures live in the `Textures(NW4R)` folder and are
  wired to materials purely by matching names.

  Texel data starts at `ofs_data` (0x40 in every observed file) and each
  mipmap follows the previous one, each dimension halving, every level
  padded up to the format's block size.
seq:
  - id: header
    type: brres_sub_header
  - id: ofs_data
    type: u4
    doc: Offset from the start of this TEX0 to the first mipmap's texel data.
  - id: ofs_name
    type: u4
    doc: |
      Offset from the start of this TEX0 to the texture's name in the
      container string pool. Zero in a standalone extraction, where the
      pool is not present.
  - id: has_palette
    type: u4
    doc: |
      1 when `format` is colour-indexed and a same-named PLT0 supplies the
      colours, 0 otherwise.
  - id: width
    type: u2
  - id: height
    type: u2
  - id: format
    type: u4
    enum: gx_texture_format
  - id: num_images
    type: u4
    doc: Mipmap level count, including the base level; 1 means no mipmaps.
  - id: reserved
    type: u4
  - id: min_lod
    type: f4
  - id: max_lod
    type: f4
    doc: |
      LOD clamp for the sampler. Both are 0.0 throughout the Animal
      Crossing: City Folk set, whose textures are all single-level.
  - id: reserved2
    size: 16
instances:
  name:
    pos: ofs_name - 4
    type: pooled_string
    if: ofs_name != 0
    doc: |
      The container string pool stores a u4 length immediately before the
      characters, so the pooled name starts four bytes before `ofs_name`.
  data:
    pos: ofs_data
    size: header.len_file - ofs_data
    doc: All mipmap levels, concatenated, in GX tiled order.
types:
  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
enums:
  gx_texture_format:
    0: i4
    1: i8
    2: ia4
    3: ia8
    4: rgb565
    5: rgb5a3
    6: rgba8
    8: ci4
    9: ci8
    10: ci14x2
    14: cmpr
