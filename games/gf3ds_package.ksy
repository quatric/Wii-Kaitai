meta:
  id: gf3ds_package
  file-extension: bin
  endian: le
  title: Game Freak GFPackage (Gen6/Gen7 3DS package)
doc: |
  Simple 3DS-era archive used by Game Freak's Gen6/Gen7 titles (Pokemon
  X/Y, Omega Ruby/Alpha Sapphire, Sun/Moon), as reimplemented from
  gdkchan/SPICA's `Formats/Packages/GFPackage` in nintoolbox's
  `lib-gf3ds.c` (`IsGFPackage`).

  No fixed magic: the format is identified structurally by a 2-uppercase-
  ASCII-byte tag followed by a u16 member count and a monotonically
  non-decreasing `count + 1`-entry offset table (the last entry is the
  end-of-file/end-of-last-member sentinel). Other formats besides
  GFModelPack/GFTexture/GFMotion blobs (which have their own magics, see
  `lib-gf3ds.h`) can be embedded as members; this definition only exposes
  the container framing.
seq:
  - id: tag
    type: str
    size: 2
    encoding: ASCII
    doc: Two uppercase ASCII letters identifying the package kind.
  - id: count
    type: u2
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count + 1
    doc: |
      Absolute member offsets; entry `count` is the sentinel marking the
      end of the last member (so member i's size is offsets[i+1] - offsets[i]).
instances:
  members:
    type: member(_index)
    repeat: expr
    repeat-expr: count
types:
  member:
    params:
      - id: idx
        type: u4
    instances:
      body:
        io: _root._io
        pos: _root.offsets[idx]
        size: _root.offsets[idx + 1] - _root.offsets[idx]
