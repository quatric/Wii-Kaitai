meta:
  id: mkw_lecode
  file-extension: bin
  application: Mario Kart Wii (LE-CODE engine binary, "LECT")
  endian: be
doc: |
  LE-CODE's compiled binary ("LECT" magic), as parsed by
  `lib-lecode.c`/`lib-lecode.h` of Wiimms SZS Tools. LE-CODE is the
  custom-track/physics engine patch that replaces Nintendo's StaticR.rel
  for CTGP-style Mario Kart Wii setups; this is the loader-relocatable
  code blob (region- and build-mode specific) plus its embedded parameter
  block.

  The file header itself is versioned (`le_binary_head_t`, a union of
  `le_binary_head_v3_t`/`v4_t`/`v5_t`): every version shares the same
  first 0x20 bytes (magic, `version`, build number, load/entry
  addresses, file size, `off_param` pointing at the embedded `LPAR`
  parameter block, region/build-mode/phase bytes); v5 then keeps growing
  with additional trailer fields across sub-revisions
  (`le_binary_head_v5_34_t` through `_44_t`, 0x34..0x44 bytes), each
  strictly extending the previous one. This definition reads the common
  v5 (0x44-byte) superset, which is also byte-compatible with every
  smaller v3/v4/v5 header as a prefix.

  `off_param` locates an independently-versioned `le_binary_param_t`
  ("LPAR" magic) parameter block, whose payload (`le_lpar_t` --
  developer/cheat/online-limit/chat-mode settings, etc.) has grown
  through more than a dozen incompatible on-disk revisions
  (`le_binpar_v1_35_t` ... `le_binpar_v1_277_t`, keyed by `size`). Only
  the small, stable `LPAR` sub-header (magic/version/size/`off_eod`) is
  modeled here; the version-specific settings payload is exposed as raw
  bytes -- picking the right one of the dozen-plus revisions to decode
  it requires the same size-based dispatch `lib-lecode.c` performs at
  runtime, which is out of scope for a static struct definition.

  Two smaller, distinct LE-CODE data files share this same tool but are
  not modeled here: `CUP2`/`CRS2`-tagged cup/course parameter lists
  (`le_cup_par_t`/`le_course_par_t`, thin wrappers with no further
  documented fixed layout in the header beyond their tag) and the
  human-readable `#LE-LPAR` text form of the parameter block (handled by
  `ScanTextLPAR()`, a distinct textual encoding, not a binary format).
seq:
  - id: magic
    contents: "LECT"
  - id: version
    type: u4
    doc: 3, 4 or 5; selects which trailer fields beyond offset 0x20 are valid.
  - id: build_number
    type: u4
    doc: LE-CODE code revision.
  - id: base_address
    type: u4
    doc: Memory address this binary is relocated to.
  - id: entry_point
    type: u4
    doc: Memory address of the prolog function.
  - id: file_size
    type: u4
  - id: off_param
    type: u4
    doc: File offset of the embedded `LPAR` parameter block.
  - id: region
    type: u1
    enum: region
    doc: "One of: P (PAL), E (NTSC-U), J (NTSC-J), K (Korea)."
  - id: build_mode
    type: u1
    enum: build_mode
    doc: "v3/v4: D or R. v5: R, T, D or X."
  - id: phase
    type: u1
    doc: ">0: development PHASE number, usually 2."
  - id: unknown_1f
    type: u1
  - id: szs_required
    type: u4
    if: version >= 5
    doc: Minimal encoded szs-tools version required to edit this binary.
  - id: edit_version
    type: u4
    if: version >= 5
    doc: ">0: encoded szs-tools version that last edited this binary."
  - id: head_size
    type: u4
    if: version >= 5
    doc: Size of this file header.
  - id: creation_time
    type: u4
    if: version >= 5
    doc: Unix time this LE-CODE binary was created.
  - id: edit_time
    type: u4
    if: version >= 5
    doc: ">0: unix time of the last edit."
  - id: szs_recommended
    type: u4
    if: version >= 5 and (_io.pos + 4) <= file_size
    doc: Recommended (not minimal) szs-tools version to manage this binary; added in a later v5 sub-revision.
  - id: commit_time
    type: u4
    if: version >= 5 and (_io.pos + 4) <= file_size
    doc: Unix time of the "git commit" this build was made from; added in a later v5 sub-revision.
  - id: off_signature
    type: u4
    if: version >= 5 and (_io.pos + 4) <= file_size
    doc: Offset of the LE-CODE signature buffer; added in the latest v5 sub-revision.
  - id: size_signature
    type: u4
    if: version >= 5 and (_io.pos + 4) <= file_size
    doc: Size of the signature buffer.
instances:
  param:
    pos: off_param
    type: binary_param
    if: off_param != 0 and off_param < file_size
types:
  binary_param:
    doc: |
      le_binary_param_t -- the stable prefix of the embedded LE-CODE
      parameter block. The actual settings payload between this header
      and `off_eod` is one of many size-keyed revisions of `le_lpar_t`
      (see class doc); left as raw bytes here.
    seq:
      - id: magic
        contents: "LPAR"
      - id: version
        type: u4
        doc: Always 1.
      - id: size
        type: u4
        doc: Size of the settings payload; also encodes the minor revision.
      - id: off_eod
        type: u4
        doc: Offset of end-of-data, relative to the start of this parameter block.
      - id: body
        size: size
        doc: |
          Version-dependent settings payload (`le_lpar_t`); layout
          selected at runtime by `size`, not decoded here.
enums:
  region:
    0x50: pal
    0x45: ntsc_u
    0x4a: ntsc_j
    0x4b: korea
  build_mode:
    0x52: release
    0x54: testcode
    0x44: debug
    0x58: debug_testcode
