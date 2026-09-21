meta:
  id: mkw_ctcode
  file-extension: bin
  application: Mario Kart Wii (Wiimms CT-CODE / LE-CODE, custom-track container)
  endian: be
doc: |
  Wiimm's CT-CODE container, as parsed by `lib-ctcode.c`/`lib-ctcode.h` of
  Wiimms SZS Tools. This is the "CT1DATA" binary embedded inside the custom
  `CTCODE` TEX0 texture (and also used standalone, e.g. as `courses.bin`
  produced by `wstrt`), listing every custom track/arena slot and cup
  assignment used by the LE-CODE / CTGP-style track engine.

  The file is a small chunked container: a fixed header names up to 6
  sections by 4-byte tag and gives an approximate offset for each, then
  each section repeats its own tag and size at its own start (so a section
  can be located and re-validated without trusting the header table
  alone -- `IterateFilesCTCODE()` in the source re-reads `name`/`size`
  straight from the section body). Only `CUP1` (cup list) and `CRS1`
  (track list) are modeled with real fields here; `MOD1`, `MOD2` and
  `OVR1` are LE-CODE binary patch/overlay blobs with no documented public
  layout, so they are exposed as raw bytes.

  Two header magics exist: `CT0_DATA_MAGIC_NUM` (0xbad0da7a, the original
  CT-CODE format) and `CT1_DATA_MAGIC_NUM` (0xbad1da7a, current LE-CODE
  format). Both share this same section-table layout.
seq:
  - id: magic
    type: u4
    enum: magic
    doc: 0xbad0da7a (CT0DATA) or 0xbad1da7a (CT1DATA, current).
  - id: len_file
    type: u4
    doc: Total size of the CT-CODE data, in bytes.
  - id: unknown_08
    type: u4
  - id: num_sections
    type: u4
    doc: Number of used entries in `section_info` (max 6).
  - id: padding
    type: u4
    repeat: expr
    repeat-expr: 4
  - id: section_info
    type: section_info
    repeat: expr
    repeat-expr: 6
    doc: |
      Fixed-size table of up to 6 sections. Only the first `num_sections`
      entries are meaningful; unused entries are zeroed. Each entry's
      `off` is relative to the start of this file.
types:
  section_info:
    seq:
      - id: ofs_section
        type: u4
      - id: name
        type: str
        size: 4
        encoding: ASCII
    instances:
      body:
        io: _root._io
        pos: ofs_section
        type:
          switch-on: name
          cases:
            '"CUP1"': cup1_section
            '"CRS1"': crs1_section
            _: raw_section
        if: ofs_section != 0

  raw_section:
    doc: |
      MOD1/MOD2/OVR1 (or any other unrecognized section): LE-CODE binary
      patch/overlay data with no documented public structure. Only the
      repeated tag/size header is parsed; the payload is left opaque.
    seq:
      - id: name
        type: str
        size: 4
        encoding: ASCII
      - id: len_section
        type: u4
      - id: body
        size: len_section - 8

  cup1_section:
    doc: |
      `CUP1`: list of racing-cup and battle-cup slots, each referencing up
      to 5 track/arena slots. `ctcode_cup1_head_t` / `ctcode_cup1_data_t`
      in the source.
    seq:
      - id: name
        contents: "CUP1"
      - id: len_section
        type: u4
      - id: unknown_08
        type: u4
      - id: num_racing_cups
        type: u4
      - id: num_battle_cups
        type: u4
      - id: unknown_14
        type: u4
        repeat: expr
        repeat-expr: 11
        doc: Observed as 5 records of 0x800 followed by 6 of 0x000 (purpose unknown).
      - id: cups
        type: cup1_entry
        repeat: expr
        repeat-expr: (len_section - 0x40) / 0x100
        doc: |
          Every defined cup slot (racing and battle back to back); the
          first `num_racing_cups` entries are racing cups, the rest are
          battle cups.
    types:
      cup1_entry:
        seq:
          - id: name
            size: 128
            doc: UTF-16BE cup name, 64 code units. Not used by the game engine.
          - id: track_id
            type: u4
            repeat: expr
            repeat-expr: 5
            doc: Index of each of the (up to) 5 tracks/arenas assigned to this cup.
          - id: unknown_84
            size: 108
            doc: Padding / unused, 0x1b u32 words in the source.

  crs1_section:
    doc: |
      `CRS1`: the actual track/arena slot table -- one entry per custom
      track or battle-arena slot, with music and property (physics/track
      parameter set) indices. `ctcode_crs1_head_t` / `ctcode_crs1_data_t`
      in the source.
    seq:
      - id: name
        contents: "CRS1"
      - id: len_section
        type: u4
      - id: unknown_08
        type: u4
      - id: num_tracks
        type: u4
      - id: unknown_10
        type: u4
        doc: Observed value 0x2a; possibly the index of the first non-arena track.
      - id: property
        type: u4
        repeat: expr
        repeat-expr: 8
        doc: |
          Flags for (at least) the first 8 cups. Seen values 0x400 (no
          sound) / 0x800 (sound).
      - id: unknown_34
        type: u4
        repeat: expr
        repeat-expr: 3
        doc: Always seen as 0; likely padding.
      - id: tracks
        type: crs1_entry
        repeat: expr
        repeat-expr: (len_section - 0x40) / 0x100
    types:
      crs1_entry:
        seq:
          - id: track_name
            size: 128
            doc: UTF-16BE track name, 64 code units. Not used by the game engine.
          - id: filename
            type: strz
            size: 64
            encoding: ASCII
            doc: File name of the track (e.g. a `.szs` base name).
          - id: music_id
            type: u4
            doc: Music slot index used by this track.
          - id: property_id
            type: u4
            doc: Track-parameter (physics/property) slot index.
          - id: cup_id
            type: u4
            doc: Cup index this slot belongs to. Informational; not used at runtime.
          - id: unknown_cc
            size: 52
            doc: Padding, 0x0d u32 words in the source.
enums:
  magic:
    0xbad0da7a: ct0_data
    0xbad1da7a: ct1_data
