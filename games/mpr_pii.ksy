meta:
  id: mpr_pii
  file-extension: bin
  endian: be
  doc: |
    My Pokémon Ranch (WiiWare) Ranch Model ("Pii") Table.
    Stride 0x20 bytes per entry (~651 entries).
seq:
  - id: entries
    type: pii_entry
    repeat: eos
types:
  pii_entry:
    seq:
      - id: packed_species_form_gender
        type: u2
        doc: "species << 7 | form << 2 | gender (gender: 0=any, 1=male, 2=female)."
      - id: flags1
        type: u1
        doc: High nibble = texture bank; bits 2-3 = class field.
      - id: padding1
        size: 5
      - id: model_name_male_offset
        type: u4
      - id: model_name_female_offset
        type: u4
      - id: scale
        type: f4
      - id: size
        type: f4
      - id: flags2
        type: u4

enums:
  gender:
    0: any_or_genderless
    1: male
    2: female
