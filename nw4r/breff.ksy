meta:
  id: breff
  file-extension: breff
  endian: be
  title: NW4R BREFF particle-effect archive
doc: |
  The `REFF` container Mario Kart Wii and New Super Mario Bros. Wii ship
  particle-effect definitions in, alongside the matching `BREFT` texture
  archive. Unlike BRRES's MDL0/TEX0 sub-formats, BREFF/BREFT effect data
  has no equivalent in the earlier GameCube NW4C middleware -- it is
  Revolution-only, tied to the `EFT` particle library, and is far less
  documented by the Brawl modding community than BRRES proper: BrawlBox
  and BrawlCrate can view and export the textures inside a BREFT, but
  neither ever gained a structural editor for BREFF's own effect
  definitions, and most public notes on the format come from reverse
  engineering the MKW/NSMBW binaries rather than a leaked SDK header.

  It reuses the exact same 16-byte header shape as BRRES (magic, bom,
  version, file size, root offset, section count) with a different magic
  and version (9 for MKW, 11 for NSMB); see `breff_root_head_t` /
  `breff_root_t` / `breff_item_list_t` in `lib-breff.h` and the reading
  code in `IterateFilesBREFF()` (`lib-breff.c`).

  Right after the header sits a second `REFF`-tagged block (the "root
  header") whose payload is the root record: a pointer to the item list,
  three fields that are always zero on real MKW files, and an inline
  NUL-terminated name. Each named item in the list below is one particle
  effect set (an `EffectSet`/"reff" record referenced by name from the
  game's effect-table binary), not a single-effect blob -- so a BREFF
  typically holds many effects addressed by name, the same folder-by-name
  convention BRRES uses for its own sub-files.
seq:
  - id: magic
    contents: "REFF"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 9 on Mario Kart Wii, 11 on New Super Mario Bros. Wii.
  - id: len_file
    type: u4
  - id: root_off
    type: u2
    doc: Always 0x10 in practice (immediately after this header).
  - id: num_sections
    type: u2
instances:
  root_header:
    pos: root_off
    type: root_header
types:
  root_header:
    seq:
      - id: magic
        contents: "REFF"
      - id: len_data
        type: u4
        doc: Size of `root`, in bytes.
      - id: root
        type: root
        size: len_data

  root:
    seq:
      - id: first_item_off
        type: u4
        doc: Offset of the `item_list`, relative to the start of this `root`.
      - id: unknown1
        type: u4
        doc: Always 0 on Mario Kart Wii samples.
      - id: unknown2
        type: u4
        doc: Always 0 on Mario Kart Wii samples.
      - id: len_name0
        type: u2
        doc: Name length including the terminating NUL.
      - id: unknown3
        type: u2
        doc: Always 0 on Mario Kart Wii samples.
      - id: name
        type: strz
        encoding: ASCII
    instances:
      item_list:
        pos: first_item_off
        type: item_list
        io: _io

  item_list:
    seq:
      - id: len_items
        type: u4
        doc: Size of all items, in bytes.
      - id: num_items
        type: u2
      - id: unknown1
        type: u2
      - id: items
        type: item_name
        repeat: expr
        repeat-expr: num_items

  item_name:
    doc: |
      A NUL-terminated name (length-prefixed by `len_name0`, which
      includes the terminator) followed immediately -- not aligned -- by
      an `item_data` offset/size pair.
    seq:
      - id: len_name0
        type: u2
      - id: name
        type: str
        size: len_name0 - 1
        encoding: ASCII
      - id: name_terminator
        size: 1
      - id: data
        type: item_data

  item_data:
    seq:
      - id: ofs_data
        type: u4
        doc: Data offset, relative to the start of the item list.
      - id: len_data
        type: u4
