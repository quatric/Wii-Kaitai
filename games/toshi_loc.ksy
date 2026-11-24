meta:
  id: toshi_loc
  title: Blue Tongue Toshi terrain locators (Barnyard Wii)
  endian: be
doc: |
  After OpenBarnyard ATerrainLocator.h. Locators = {s32 count, ptr locators,
  u32 name count, ptr name table}; LocatorVIS = {s32 section count, ptr
  sections}, a section {ptr name, u32 first locator, u32 count}. Pointers are
  section offsets in the TSFB section.
seq:
  - id: count
    type: s4
  - id: locators_ptr
    type: u4
  - id: name_count
    type: u4
  - id: name_table_ptr
    type: u4
types:
  locator:
    seq:
      - id: quaternion
        type: f4
        repeat: expr
        repeat-expr: 4
        doc: x y z w.
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: name_id
        type: u2
      - id: flags1
        type: u1
        doc: Low nibble * 0.2 = scale, high nibble = flags.
      - id: flags2
        type: s1
  locator_vis:
    seq:
      - id: section_count
        type: s4
      - id: sections_ptr
        type: u4
  vis_section:
    seq:
      - id: name_ptr
        type: u4
      - id: first_locator
        type: u4
      - id: count
        type: u4
