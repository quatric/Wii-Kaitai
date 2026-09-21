meta:
  id: rbnk
  endian: be
  title: Nintendo NW4R RBNK instrument bank (Wii)
doc: |
  NW4R "RBNK" instrument bank, per lib-rbnk.c/.h. An RBNK does not hold
  any audio itself -- it is the piece that turns a raw waveform (an
  `nw4r/rwav.ksy` sample, in an `RWAR` archive or this file's own `WAVE`
  section) into a *playable instrument*: which sample to use for which
  MIDI-style note range, at what pitch offset, envelope and pan. An
  `nw4r/sequence.ksy` (BRSEQ) track's "program change" event selects one
  instrument out of a paired RBNK by index; the bank is what the sequence
  player consults on every note-on to resolve pitch -> sample. This
  three-layer split (BRSEQ bytecode -> RBNK instrument mapping -> RWAV/RWAR
  sample data) mirrors a General MIDI synthesizer's separation of a MIDI
  file, a patch/soundfont, and PCM sample ROM, and is the same division
  BrawlBox/BrawlLib exposed when it let modders "reskin" Brawl's music by
  swapping instruments without touching the RSEQ bytecode.

  Models the fixed header and the DATA/WAVE ruint-list containers; the
  note-lookup tree inside DATA (RangeTable/IndexTable/InstParam, ported
  from BrawlLib) is recursive with offsets always relative to the top of
  the DATA ruint list, so it is left as a raw byte span here rather
  than reproduced -- see lib-rbnk.h for the documented tree-walk
  semantics. In broad strokes (per BrawlLib's RBNK reader, not verified
  byte-exact here): an `inst` entry may point directly at note parameters
  or at a `range`/`index` node that keys off the incoming note number to
  pick a child entry, so instruments with per-key-range samples (a piano
  spanning many octaves from a handful of recorded notes, for instance)
  resolve through one or more levels of that tree before reaching the
  actual `InstParam` (sample index into WAVE/RWAR, base pitch, volume,
  pan, ADSR-style envelope). WAVE is only present for version-minor < 2
  banks; version >= 2 references an embedded RWAR archive instead --
  matching the same generational split BrawlBox documents between
  "old-style" banks with inline waves and newer ones that reference a
  separate wave archive so multiple banks can share it.
seq:
  - id: magic
    contents: "RBNK"
  - id: file_size
    type: u4
  - id: version_major
    type: u1
  - id: version_minor
    type: u1
    doc: |
      Selects whether `wave` (an inline `WAVE` ruint list) or an external
      RWAR archive supplies this bank's sample data; see the top-level doc.
  - id: unknown_08
    size: 8
    doc: |
      Unidentified; plausibly BOM/reserved padding matching the pattern
      other NW4R headers (BRSAR, RWAV) use at this position, but not
      confirmed against a documented field for RBNK specifically.
  - id: data_off
    type: u4
    doc: Absolute file offset of the `DATA` section (the instrument/note-lookup tree).
  - id: unknown_14
    type: u4
  - id: wave_off
    type: u4
    doc: |
      Absolute file offset of the inline `WAVE` section. Zero when this
      bank instead references an external RWAR (version_minor >= 2), in
      which case the sample indices inside `DATA`'s `InstParam` entries
      are looked up in that RWAR rather than here.
instances:
  data:
    pos: data_off
    type: ruint_list_section
    io: _io
  wave:
    pos: wave_off
    type: ruint_list_section
    io: _io
    if: wave_off != 0
types:
  ruint_list_section:
    doc: |
      A "reference/resource uint" list: a small header naming how many
      tagged offsets follow, each one either a top-level instrument (for
      `DATA`) or a top-level wave (for `WAVE`). BrawlLib's reader treats
      this the same generic way for both sections, which is why one type
      here serves both -- only the meaning of `entry_type` on the leaf
      entries differs by which section they came from.
    seq:
      - id: magic
        size: 4
        doc: '"DATA" or "WAVE".'
      - id: section_size
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: ruint
        repeat: expr
        repeat-expr: num_entries
  ruint:
    doc: |
      1-byte type tag + 3-byte offset, relative to the enclosing entries
      list's own start. This packed 4-byte cell is the recurring building
      block of the DATA note-lookup tree: an `inst` entry's offset lands on
      an `InstParam`, but a `range` or `index` entry's offset lands on
      *another* `ruint_list_section`-shaped node one level down, keyed by
      note number -- which is how one instrument slot can fan out into a
      whole keyboard's worth of per-range samples without a fixed-size
      table. `null_entry` marks an unused slot in a sparse range/index node.
    seq:
      - id: entry_type
        type: u1
        enum: entry_type_t
      - id: offset
        type: b24
enums:
  entry_type_t:
    0: invalid
    1: inst
    2: range
    3: index
    4: null_entry
