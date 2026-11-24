meta:
  id: pikmin_blo
  title: Pikmin 1 screen layout (.blo)
  file-extension: blo
  endian: be
doc: |
  Stream of u16 pane types (0 end of level, 1 begin children {u16}, 2 end {u16},
  0x10 pane, 0x11 window, 0x12 picture, 0x13 text box); each pane {u8 visible,
  u8, char tag[4], s16 x, y, w, h} plus type-specific fields (resource names,
  colours, text).
seq:
  - id: items
    type: item
    repeat: eos
types:
  item:
    seq:
      - id: type
        type: u2
      - id: child_marker
        type: u2
        if: type == 1 or type == 2
      - id: pane
        type: pane
        if: type >= 0x10
  pane:
    seq:
      - id: visible
        type: u1
      - id: unk
        type: u1
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: x
        type: s2
      - id: y
        type: s2
      - id: w
        type: s2
      - id: h
        type: s2
