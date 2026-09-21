meta:
  id: dds
  file-extension: dds
  endian: le
  title: Microsoft DirectDraw Surface image
doc: |
  Standard DirectX texture container. Nintendo tools (this project's own
  `lib-dds.c`) read it as an interchange format for texture extraction and
  rebuilding: a 4-byte magic, a fixed 124-byte `DDS_HEADER`, an optional
  20-byte `DDS_HEADER_DXT10` extension (present when the pixel format's
  FourCC is `DX10`), and the raw pixel payload (block-compressed for BCn/
  ASTC DXGI formats, or packed per the RGB/alpha bit masks otherwise).

  `DecodeDDS_RGBA()` only actually reads `header.size` (must be 124),
  `height`, `width`, and, from the pixel format, `flags`, `four_cc`,
  `rgb_bit_count` and the four channel masks -- plus `dxgi_format` from the
  DXT10 extension when `four_cc` is `DX10`. The remaining header fields
  (pitch, mip count, caps, ...) are modeled here for completeness from the
  well-known Microsoft layout but are not validated by this codebase.
seq:
  - id: magic
    contents: "DDS "
  - id: header
    type: dds_header
  - id: header_dxt10
    type: dds_header_dxt10
    if: header.pixel_format.four_cc == "DX10"
  - id: payload
    size-eos: true
    doc: |
      Block-compressed or packed pixel data, starting right after the
      DXT10 extension when present, otherwise right after `header`.
types:
  dds_header:
    seq:
      - id: size
        type: u4
        doc: Must be 124.
      - id: flags
        type: u4
      - id: height
        type: u4
      - id: width
        type: u4
      - id: pitch_or_linear_size
        type: u4
      - id: depth
        type: u4
      - id: mip_map_count
        type: u4
      - id: reserved1
        size: 44
        doc: 11 reserved u32 fields.
      - id: pixel_format
        type: dds_pixel_format
      - id: caps
        type: u4
      - id: caps2
        type: u4
      - id: caps3
        type: u4
      - id: caps4
        type: u4
      - id: reserved2
        type: u4
  dds_pixel_format:
    seq:
      - id: size
        type: u4
        doc: Must be 32.
      - id: flags
        type: u4
        doc: |
          Bit 0x1 = alpha pixels present, 0x2 = alpha-only, 0x4 = FourCC
          valid (`four_cc`), 0x40 = uncompressed RGB, 0x200 = YUV,
          0x20000 = luminance-only.
      - id: four_cc
        type: str
        size: 4
        encoding: ASCII
        doc: |
          e.g. "DXT1".."DXT5", "ATI1"/"ATI2"/"BC4U"/"BC4S"/"BC5U"/"BC5S",
          or "DX10" when the real format lives in the DXT10 extension's
          `dxgi_format` instead of this FourCC.
      - id: rgb_bit_count
        type: u4
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
      Present only when `pixel_format.four_cc` is "DX10". Only
      `dxgi_format` is read by `DecodeDDS_RGBA()`, which understands BC1-7,
      the ASTC 4x4..12x12 range and a handful of float formats.
    seq:
      - id: dxgi_format
        type: u4
        enum: dxgi_format
      - id: resource_dimension
        type: u4
      - id: misc_flag
        type: u4
      - id: array_size
        type: u4
      - id: misc_flags2
        type: u4
enums:
  dxgi_format:
    70: bc1_typeless
    71: bc1_unorm
    72: bc1_unorm_srgb
    83: bc4_typeless
    84: bc4_unorm
    85: bc4_snorm
    86: bc5_typeless
    87: bc5_unorm
    88: bc5_snorm
    94: bc6h_uf16
    95: bc6h_typeless
    96: bc6h_sf16
    98: bc7_unorm
    99: bc7_unorm_srgb
