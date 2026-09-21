meta:
  id: gtx
  file-extension:
    - gtx
    - gsh
  endian: be
  title: Wii U "Gfx2" GX2 texture/shader container (GTX/GSH)
doc: |
  Wii U GX2 texture ("GTX") and shader ("GSH") container: a 32-byte file
  header followed by a chain of "BLK{"-tagged blocks, terminated by a
  zero-size type-1 block. Textures are stored in the Latte GPU's tiled
  surface layout and need a separate detiling pass to become linear RGBA;
  this definition only exposes the container structure, not decoded pixels.
  Ported from lib-gtx.c's `ScanGTX`.
seq:
  - id: magic
    contents: "Gfx2"
  - id: header_size
    type: u4
    doc: Always 32 in known samples.
  - id: version_major
    type: u4
  - id: version_minor
    type: u4
  - id: gpu_version
    type: u4
    doc: Always 2.
  - id: alignment
    type: u4
  - id: unknown_18
    size: 8
  - id: blocks
    type: block
    repeat: eos
types:
  block:
    seq:
      - id: magic
        contents: "BLK{"
      - id: header_size
        type: u4
        doc: Size of this block's header, at least 32.
      - id: unknown_08
        size: 8
      - id: type
        type: u4
        doc: |
          Block type tag. The texture-header/image-data/mip-data triple
          uses type N/N+1/N+2 where N is 0x0A for GTX version 6.0 and 0x0B
          for every other known version (6.x/7.x) -- this is a runtime
          value, not a fixed constant, so it is not modeled as an enum
          here. Shader stages use fixed tags instead: 3/5 (vertex
          header/program), 6/7 (pixel), 8/9/10 (geometry header/program/
          copy-program), 14/15 (compute header/program). A trailing
          type-1 block with `data_size` 0 terminates the block chain.
      - id: data_size
        type: u4
      - id: header_tail
        size: header_size - 24
        doc: Remaining header bytes not modeled here (header_size may exceed 32).
      - id: body
        size: data_size
        doc: |
          Raw block payload. For a texture-header block (see `type`) this
          is a `gx2_texture` structure; callers know N from the file's
          version fields and can re-interpret accordingly.
  gx2_texture:
    doc: |
      GX2Texture: a GX2Surface (16 u32) plus 13 mip-level byte offsets,
      a texture view (4 u32), 4 component-selector bytes, and 5 reserved
      GX2 register words (136 bytes total; a trailing texRegs tail may
      follow depending on version, matched by the parent block's size).
    seq:
      - id: dim
        type: u4
        enum: gx2_surface_dim
      - id: width
        type: u4
      - id: height
        type: u4
      - id: depth
        type: u4
      - id: num_mips
        type: u4
      - id: format
        type: u4
        doc: Raw GX2SurfaceFormat word.
      - id: aa
        type: u4
      - id: use
        type: u4
      - id: unknown_20
        size: 16
      - id: tile_mode
        type: u4
      - id: swizzle
        type: u4
      - id: unknown_38
        size: 4
      - id: pitch
        type: u4
      - id: mip_offsets
        type: u4
        repeat: expr
        repeat-expr: 13
      - id: view_first_mip
        type: u4
      - id: view_num_mips
        type: u4
      - id: view_first_slice
        type: u4
      - id: view_num_slices
        type: u4
      - id: comp_sel
        size: 4
      - id: tex_regs
        size-eos: true
enums:
  gx2_surface_dim:
    0: dim_1d
    1: dim_2d
    2: dim_3d
    3: dim_cube
    4: dim_1d_array
    5: dim_2d_array
    6: dim_2d_msaa
    7: dim_2d_msaa_array
