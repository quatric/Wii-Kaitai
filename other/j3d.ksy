meta:
  id: j3d
  file-extension:
    - bmd
    - bdl
  application: Nintendo J3D (GameCube/Wii binary model, BMD/BDL)
  endian: be
doc: |
  Nintendo's J3D binary model container, used across many GameCube and Wii
  titles (including Mario Kart Wii's course/object models). Parsed by
  `lib-j3d.c`/`lib-j3d.h` of Wiimms SZS Tools (`ParseJ3D()`,
  `j3d_find_sections()`), which reaches feature parity with SuperBMD.

  The file starts with an 8-byte magic ("J3D2" + one of "bmd3"/"bmd2"/
  "bdl4": BMD = model only, BDL = model + baked display list), followed
  by the total file size and section count, then 16 padding/"version"
  bytes the source treats as an opaque dummy block (`pos = 32` is where
  the first section starts: 8 magic + 4 size + 4 count + 16 dummy).

  Every top-level chunk is then a self-describing, self-sized TLV: a
  4-byte tag and a 4-byte size (including the 8-byte tag+size header),
  chunks packed back to back until EOF. Known tags (`j3d_find_sections()`):
  `INF1` (scenegraph), `VTX1` (vertex pools), `EVP1` (envelopes/skinning),
  `DRW1` (bone-weight slots), `JNT1` (joints), `SHP1` (shapes/geometry),
  `MAT3`/`MAT4` (materials), `MDL3` (compiled display lists, BDL only),
  `TEX1` (textures). Each chunk's internal layout is GX-pipeline specific
  and highly version/game dependent (materials, shapes and textures alone
  span thousands of lines of decode logic in `lib-j3d.c`), so only the
  common outer TLV framing is modeled here; chunk payloads are exposed as
  raw bytes for further, format-specific parsing.
seq:
  - id: magic
    contents: "J3D2"
  - id: subtype
    type: str
    size: 4
    encoding: ASCII
    doc: "bmd3 or bmd2: model only (BMD). bdl4: model + baked display list (BDL)."
  - id: file_size
    type: u4
  - id: num_sections
    type: u4
  - id: padding
    size: 16
    doc: |
      16 bytes treated as an opaque dummy/version block by the source
      (not decoded); real J3D files usually store an SVR3-style tag here.
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_section
        type: u4
        doc: Total chunk size in bytes, including this 8-byte tag+size header.
      - id: body
        size: len_section - 8
