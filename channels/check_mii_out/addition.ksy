meta:
  id: addition
  file-extension:
    - ces
    - dec
  endian: be
  doc: |
    Check Mii Out Channel Addition Data (AD tag).
    Contains preset Miis (NH), artisan profiles (NJ), and header metadata (NW).
seq:
  - id: type
    contents: "AD"
  - id: padding1
    size: 2
  - id: country_region
    type: u4
  - id: parameter
    type: u4
  - id: error_code
    type: u4
  - id: padding2
    size: 16
  - id: sub_tag
    contents: "AD"
  - id: sub_tag_size
    type: u2
  - id: unknown
    type: u4
  - id: entry_count
    type: u4
  - id: preset_miis
    type: preset_mii
    repeat: expr
    repeat-expr: 255
    doc: NH sub-tag (max 255 entries, 0x80 bytes each).
  - id: artisan_profiles
    type: artisan_profile
    repeat: expr
    repeat-expr: 255
    doc: NJ sub-tag (max 255 entries, 0x40 bytes each).
  - id: header_metadata
    type: header_meta
    doc: NW sub-tag (max 1 entry).
types:
  preset_mii:
    seq:
      - id: data
        size: 128
  artisan_profile:
    seq:
      - id: data
        size: 64
  header_meta:
    seq:
      - id: data
        size-eos: true
