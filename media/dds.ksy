meta:
  id: dds
  file-extension: dds
  endian: le
  title: Microsoft DirectDraw Surface texture
doc: |
  Standard Microsoft DDS, as read by `lib-dds.c` of Wiimms SZS Tools
  (`DecodeDDS_RGBA`). This models the header fields that code actually
  reads, plus the well-known surrounding `DDS_HEADER` layout so the file
  parses fully; fields the tool ignores (pitch, mip count, caps, the
  eleven reserved words) are kept only as raw values since nothing in
  this codebase gives them special meaning.

  `IsDDS()` only checks the 4-byte magic and that the file is at least
  128 bytes; `DecodeDDS_RGBA()` additionally requires `header_size == 124`
  and rejects width/height of 0 or greater than 16384. The reader supports
  two payload shapes:

  * Legacy FourCC-tagged block compression -- `DXT1`/`DXT2`/`DXT3`/`DXT4`/
    `DXT5` (BC1/BC2/BC3 equivalents) -- payload starts right after the
    124-byte header, i.e. at offset 128.
  * `DX10`: an extra 20-byte `DDS_HEADER_DXT10` follows the main header
    (payload then starts at offset 148), carrying a `dxgi_fmt` that
    selects BC1-BC7 or an uncompressed DXGI format; the source's switch
    covers BC1-BC7 plus several ASTC-range formats (dxgi_fmt <= 183) by
    block-size lookup table rather than by name.

  Uncompressed (non-FourCC) formats are decoded generically from
  `rgb_bit_count`/`r_mask`/`g_mask`/`b_mask`/`a_mask`, matching the
  classic `DDPF_RGB`/`DDPF_ALPHA` pixel-format path.
seq:
  - id: magic
    contents: "DDS "
  - id: header
    type: dds_header
  - id: payload
    size-eos: true
    doc: |
      Block-compressed or packed pixel data, starting right after the
      DXT10 extension when present (offset 148), otherwise right after
      `header` (offset 128).
types:
  dds_header:
    doc: DDS_HEADER, always 124 bytes including this size field.
    seq:
      - id: header_size
        type: u4
        doc: Must be 124; `DecodeDDS_RGBA` rejects anything else.
      - id: flags
        type: u4
        doc: DDSD_* capability flags (which fields below are valid). Not checked by the tool.
      - id: height
        type: u4
      - id: width
        type: u4
      - id: pitch_or_linear_size
        type: u4
      - id: depth
        type: u4
        doc: Depth for volume textures. Unused by the tool.
      - id: mip_map_count
        type: u4
        doc: Unused by the tool; mip levels are not decoded here.
      - id: reserved1
        type: u4
        repeat: expr
        repeat-expr: 11
      - id: pixel_format
        type: pixel_format
      - id: caps
        type: u4
        doc: DDSCAPS_* (e.g. COMPLEX/MIPMAP/TEXTURE). Unused by the tool.
      - id: caps2
        type: u4
        doc: DDSCAPS2_* (cubemap faces, volume). Unused by the tool.
      - id: caps3
        type: u4
      - id: caps4
        type: u4
      - id: reserved2
        type: u4
    instances:
      is_dx10:
        value: (pixel_format.flags & 0x4) != 0 and pixel_format.four_cc == 0x30315844
        doc: DDPF_FOURCC set and FourCC == "DX10".
      dx10_header:
        type: dds_header_dxt10
        if: is_dx10
        doc: Only present when `is_dx10`; adds 20 bytes right after this header.
    types:
      pixel_format:
        doc: DDS_PIXELFORMAT, 32 bytes.
        seq:
          - id: size
            type: u4
            doc: Must be 32 (not explicitly checked by the tool).
          - id: flags
            type: u4
            doc: |
              DDPF_* flags. Bit 0x1 = DDPF_ALPHAPIXELS, 0x4 = DDPF_FOURCC,
              0x40 = DDPF_RGB (the combination the tool's generic
              uncompressed path expects).
          - id: four_cc
            type: u4
            enum: fourcc
            doc: 4CC code, meaningful only when DDPF_FOURCC is set.
          - id: rgb_bit_count
            type: u4
            doc: Total bits per pixel for the uncompressed (non-FourCC) path.
          - id: r_bit_mask
            type: u4
          - id: g_bit_mask
            type: u4
          - id: b_bit_mask
            type: u4
          - id: a_bit_mask
            type: u4
      dds_header_dxt10:
        doc: |
          DDS_HEADER_DXT10, present only when `pixel_format.four_cc` is
          `DX10`. `dxgi_format` then replaces the FourCC as the real
          compression/pixel-format selector.
        seq:
          - id: dxgi_format
            type: u4
          - id: resource_dimension
            type: u4
          - id: misc_flag
            type: u4
            doc: e.g. DDS_RESOURCE_MISC_TEXTURECUBE.
          - id: array_size
            type: u4
          - id: misc_flags2
            type: u4
enums:
  fourcc:
    0x31545844: dxt1
    0x32545844: dxt2
    0x33545844: dxt3
    0x34545844: dxt4
    0x35545844: dxt5
    0x30315844: dx10
