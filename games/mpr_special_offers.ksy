meta:
  id: mpr_special_offers
  file-extension: dat
  endian: be
  doc: |
    My Pokémon Ranch Special Pokémon Offers Table.
    Stride 0x10 bytes per entry (27 slots).
seq:
  - id: offers
    type: offer_entry
    repeat: eos
types:
  offer_entry:
    seq:
      - id: species
        type: u2
        enum: special_species
      - id: padding1
        size: 2
      - id: filename_offset
        type: u4
        doc: Offset to string like "normal01.dat" or "special1.dat".
      - id: is_special
        type: u1
      - id: padding2
        size: 1
      - id: milestone_count
        type: u2
        doc: Required Pokémon-count milestone.
      - id: second_threshold
        type: u2
      - id: padding3
        size: 1
      - id: level
        type: u1

enums:
  special_species:
    427: buneary
    397: staravia
    285: shroomish
    456: finneon
    417: pachirisu
    77: ponyta
    422: shellos
    453: croagunk
    459: snover
    25: pikachu
    320: wailmer
    241: miltank
    193: yanma
    108: lickitung
    360: wynaut
    133: eevee
    142: aerodactyl
    37: vulpix
    114: tangela
    415: combee
    489: phione
