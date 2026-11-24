meta:
  id: pikmin_anm
  title: Pikmin 1 animation / texture bundle (.anm, .bun)
  file-extension: bun
  endian: be
doc: |
  Pikmin 1 `.anm` animation bundles and `.bun` texture / effect bundles
  (`StdSystem::loadBundle` in the decompilation). `.bun` entries keep their stored
  directory paths.
seq:
  - id: count
    type: s4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: type
        type: s4
        enum: entry_type
      - id: len_data
        type: s4
      - id: len_name
        type: s4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
      - id: data
        size: len_data
enums:
  entry_type:
    0: binary
    1: texture
    2: dca
    3: dck
