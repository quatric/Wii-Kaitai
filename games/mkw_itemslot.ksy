meta:
  id: mkw_itemslot
  file-extension:
    - bin
    - slt
  application: Mario Kart Wii (ITEMSLT, item-probability tables)
  endian: be
doc: |
  Mario Kart Wii's "ITEMSLT" item-probability table, as parsed by
  `lib-itemslot.c`/`itemslot_bin_t` in `lib-common.h` of Wiimms SZS Tools.
  This is the binary form of `ItemSlot.bin` / `ItemSlotAll.bin` (extension
  `.bin`, or `.slt` when produced by `wstrt`), a flat table of `u8`
  probabilities: for each of a fixed set of "situations" (Grand-Prix
  player/enemy, VS player/enemy/online, special item boxes, and -- if
  `add_battle` -- the 4 Balloon/Coin battle situations plus their online
  variants), one row per placement (0..18, "Green Shell".."Triple
  Bananas") and one column per race position (1st..12th, or 1st..16th for
  the "special" table).

  Every table is prefixed by its own `n_rows`/`n_cols` byte pair, mirroring
  the fixed geometry baked into the tool (`ITEMSLT_SIZE6` = 1457 bytes for
  the 6 racing tables only, `ITEMSLT_SIZE12` = 1811 bytes with the 6 extra
  battle tables appended). The very first byte of the file is `n_table`
  (6 or 12), stating which of the two sizes follows.
seq:
  - id: n_table
    type: u1
    doc: Number of tables that follow (6 = racing only, 12 = racing + battle).
  - id: gp_player
    type: item_table
    doc: Probabilities for players in Grand Prix races.
  - id: gp_enemy
    type: item_table
    doc: Probabilities for CPU enemies in Grand Prix races.
  - id: vs_player
    type: item_table
    doc: Probabilities for players in VS races.
  - id: vs_enemy
    type: item_table
    doc: Probabilities for CPU enemies in VS races.
  - id: vs_online
    type: item_table
    doc: Probabilities for players in online VS races.
  - id: special
    type: item_table
    doc: Probabilities for "special" (e.g. lightning-triggered) item boxes.
  - id: balloon_player
    type: item_table
    if: n_table >= 12
    doc: Probabilities for players in Balloon Battle.
  - id: balloon_enemy
    type: item_table
    if: n_table >= 12
    doc: Probabilities for CPU enemies in Balloon Battle.
  - id: coin_player
    type: item_table
    if: n_table >= 12
    doc: Probabilities for players in Coin Runners.
  - id: coin_enemy
    type: item_table
    if: n_table >= 12
    doc: Probabilities for CPU enemies in Coin Runners.
  - id: balloon_online
    type: item_table
    if: n_table >= 12
    doc: Probabilities for players in online Balloon Battle.
  - id: coin_online
    type: item_table
    if: n_table >= 12
    doc: Probabilities for players in online Coin Runners.
types:
  item_table:
    doc: |
      One probability table: `n_rows` item slots (index into the fixed
      19-item table, "Green Shell" being row 0) by `n_cols` finishing
      positions, one raw `u8` chance value per cell.
    seq:
      - id: n_rows
        type: u1
      - id: n_cols
        type: u1
      - id: cell
        type: u1
        repeat: expr
        repeat-expr: n_rows * n_cols
enums:
  item:
    0: green_shell
    1: red_shell
    2: banana
    3: fake_item_box
    4: mushroom
    5: triple_mushroom
    6: bob_omb
    7: blue_shell
    8: lightning
    9: star
    10: golden_mushroom
    11: mega_mushroom
    12: blooper
    13: pow_block
    14: thundercloud
    15: bullet_bill
    16: triple_green_shells
    17: triple_red_shells
    18: triple_bananas
