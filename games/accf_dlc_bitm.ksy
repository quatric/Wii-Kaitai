meta:
  id: accf_dlc_bitm
  file-extension: bitm
  application: Animal Crossing City Folk (Let's Go to the City)
  endian: be
  doc: |
    .bitm - a single downloadable item for Animal Crossing City Folk, 8192 bytes:
    item parameters, a fixed-size ASH0-compressed BRRES resource slot, and a
    trailing CRC-32.

    Source: this is NOT recovered from the retail game binary. It documents the
    format as read and written by ACDLC, the community DLC item editor/creator
    (Aurum's Mods). The distributed build ships no acdlc.py source - only a
    PyInstaller build - so this was recovered by extracting the bundled
    `bitm.py` module from the frozen app's PYZ archive and reading its Python
    3.10 bytecode. ACDLC treats the BRRES resource block as opaque: it never
    compresses or decompresses ASH0 itself, only carries the bytes through.

    ACDLC's own field names are kept here even where they read like offsets into
    a different, unpublished layout (`unk170`) - they are the tool's names, not
    ours.

seq:
  - id: header
    type: item_header
  - id: jp_name
    type: fixed_name
  - id: en_name
    type: fixed_name
  - id: es_name
    type: fixed_name
  - id: fr_name
    type: fixed_name
    doc: NOA (North America) French.
  - id: en_name_noe
    type: fixed_name
    doc: NOE (Europe) English. ACDLC seeds this from the same default as `en_name`.
  - id: de_name
    type: fixed_name
  - id: it_name
    type: fixed_name
  - id: es_name_noe
    type: fixed_name
    doc: NOE (Europe) Spanish.
  - id: fr_name_noe
    type: fixed_name
    doc: NOE (Europe) French.
  - id: kr_name
    type: fixed_name
  - id: params
    type: item_params
  - id: resource_data
    size: 7792
    doc: |
      ASH0-compressed BRRES resource, zero-padded to this fixed size
      (`ASH0_SIZE`). Starts with the 4-byte magic "ASH0" when present. ACDLC
      recomputes `params.misc_properties_1`'s 0x20 bit from this magic every
      time it loads or saves a file, rather than trusting the stored bit -
      the two can disagree in a hand-edited file.
  - id: crc32
    type: u4
    doc: |
      CRC-32 (standard zlib polynomial 0xEDB88320) over every byte before this
      field - the 396-byte header+name+params block plus the 7792-byte resource
      slot. NOT seeded from zero: ACDLC starts the running checksum at the fixed
      value 0xFBDFEFE7 instead of the usual zlib default of 0, so this field
      cannot be verified with a generic `crc32(data)` call - the seed has to be
      supplied.
types:
  item_header:
    seq:
      - id: magic
        contents: "BITM"
      - id: price
        type: s4
        doc: Signed, despite always being a positive shop price in every file ACDLC produces.
      - id: item_id
        type: u2
      - id: inventory_icon
        type: u2
      - id: furniture_kind
        type: u2
      - id: clothing_id
        type: u2
      - id: version
        type: u2
        doc: |
          Fixed at 0x1701. ACDLC hard-rejects (raises and refuses to load) any
          buffer whose version or magic doesn't match exactly, so no other
          version is known to exist.
  fixed_name:
    doc: |
      One localized item name, UTF-16BE, fixed 34-byte slot (17 code units).
      ACDLC decodes then strips NUL from both ends of the result - a name
      doesn't have to fill the slot, and any unused tail is zero-padded.
    seq:
      - id: text
        type: str
        size: 34
        encoding: UTF-16BE
  item_params:
    seq:
      - id: class_name
        type: u1
      - id: dlc_slot
        type: u1
      - id: drop_model
        type: u1
      - id: series_group
        type: u1
      - id: generator_group
        type: u1
        doc: ACDLC defaults freshly created DLC items to 16 (a bare ItemParam defaults to 0).
      - id: flooring_sound
        type: u1
      - id: clothing_set
        type: u1
      - id: pattern_creator_name
        type: u1
        doc: Despite the name, a single byte code - not a string.
      - id: pattern_creator_town
        type: u1
      - id: catalog_scale
        type: u1
        doc: Defaults to 100 (percent) on a newly created item.
      - id: unk170
        type: u1
        doc: Round-tripped by ACDLC but never interpreted by it.
      - id: furniture_function
        type: u1
      - id: instrument_type
        type: u1
      - id: sound_type
        type: u1
      - id: fossil_group
        type: u1
      - id: table_height
        type: u1
      - id: exclusive_version
        type: b4
      - id: clothing_season
        type: b4
        doc: Defaults to 4 on a newly created item.
      - id: hide_bone
        type: b4
        doc: Defaults to 10 on a newly created item.
      - id: clothing_style
        type: b4
        doc: Defaults to 10 on a newly created item.
      - id: paper_text_palette
        type: b4
      - id: pattern_palette
        type: b4
      - id: furniture_dimensions
        type: b4
      - id: furniture_color_1
        type: b4
      - id: furniture_color_2
        type: b4
      - id: furniture_type_1
        type: b4
      - id: furniture_type_2
        type: b4
        doc: Defaults to 5 on a newly created item.
      - id: grammar_noa_english_article_1
        type: b4
      - id: grammar_noa_english_article_2
        type: b4
      - id: grammar_noa_spanish_article_1
        type: b4
      - id: grammar_noa_spanish_article_2
        type: b4
      - id: grammar_noa_spanish_gender
        type: b4
      - id: grammar_noa_french_article_1
        type: b4
      - id: grammar_noa_french_article_2
        type: b4
      - id: grammar_noa_french_gender
        type: b4
      - id: grammar_noe_english_article_1
        type: b4
      - id: grammar_noe_english_article_2
        type: b4
      - id: grammar_german_article_1
        type: b4
      - id: grammar_german_article_2
        type: b4
      - id: grammar_german_gender
        type: b4
      - id: grammar_italian_article_1
        type: b4
      - id: grammar_italian_article_2
        type: b4
      - id: grammar_italian_gender
        type: b4
      - id: grammar_noe_spanish_article_1
        type: b4
      - id: grammar_noe_spanish_article_2
        type: b4
      - id: grammar_noe_spanish_gender
        type: b4
      - id: grammar_noe_french_article_1
        type: b4
      - id: grammar_noe_french_article_2
        type: b4
      - id: grammar_noe_french_gender
        type: b4
      - id: misc_properties_0
        type: b4
        doc: |
          Bit flags, English article/gender pairs above have no gender slot
          (English doesn't need one); every other language gets article_1,
          article_2 and gender. Bits here:
            0x1: is_table_like_furniture
            0x2: is_table_top_furniture
            0x4: is_normal_food
            0x8: is_special_food
      - id: misc_properties_1
        type: u1
        doc: |
          Bit flags:
            0x01: low bit of furniture_genre_1 (see misc_properties_2 bit 0x80
                  for the other half - the pair is one-hot, not 2-bit binary:
                  neither bit set means genre 0, this bit alone means genre 1)
            0x02: is_show_in_catalog
            0x04: is_pro_design
            0x10: is_not_purchasable_via_catalog
            0x20: has_resource_file (recomputed from resource_data's ASH0 magic
                  on every load/save - see resource_data above)
            0xC0: lamp_type, a 2-bit value (shift right 6)
          Bit 0x08 has no known consumer in ACDLC.
      - id: misc_properties_2
        type: u1
        doc: |
          Bit flags:
            0x02: is_disable_collision
            0x08: is_hra_lucky_item
            0x10: is_hra_subtract_wall_face
            0x20: furniture_genre_2 == 1 (paired one-hot with 0x40, same
                  scheme as furniture_genre_1)
            0x40: furniture_genre_2 == 2
            0x80: high half of furniture_genre_1 (see misc_properties_1 bit 0x01)
          Bits 0x01 and 0x04 have no known consumer.
      - id: misc_properties_3
        type: u1
        doc: Round-tripped by ACDLC; no bit in it is ever read or written by name.
      - id: reserved
        size: 2
        doc: Struct padding (Python format code `2x`); never read or written.
