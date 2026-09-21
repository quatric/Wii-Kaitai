meta:
  id: sequence
  endian:
    switch-on: _root.magic
    cases:
      '"CSEQ"': le
      '"SSEQ"': le
      _: be
  title: NintendoWare sequence container (RSEQ/CSEQ/FSEQ/SSEQ)
doc: |
  NintendoWare sound-sequence bytecode container (Wii RSEQ, 3DS
  CSEQ, Wii U/Switch FSEQ, DS SSEQ), per lib-sequence.c. It is the
  NW4R family's answer to a MIDI file: not sampled audio at all, but a
  compact, MIDI-like event stream -- note-on/note-off, wait, program
  change, jumps and subroutine calls, plus a large set of NW4R-specific
  extensions for looping, variables and conditional branches -- that a
  game's sequence player interprets against an `nw4r/rbnk.ksy` instrument
  bank to actually produce sound. This is also the DS `SSEQ` format's
  direct ancestor/sibling: RSEQ is described by community documentation
  (Custom Mario Kart wiki, vgmtrans) as "basically SSEQ with some of the
  command bytes changed," reflecting NintendoWare's shared lineage across
  the DS and Wii sound engines.

  Two shapes exist: the legacy Wii RSEQ layout with direct DATA/LABL block
  offsets, and the newer reference-table layout (CSEQ/FSEQ/SSEQ) with a
  block-type table. The bytecode itself (a large opcode set documented in
  lib-sequence.h) is not modeled here.

  ## Bytecode shape (for reference; not parsed by this definition)

  Every event in DATA starts with a status byte:

  * `0x00`-`0x7F` -- note-on: pitch, a velocity byte, then a VLQ (variable-
    length quantity, MIDI-style: high bit of each byte means "more bytes
    follow", little-endian nibble accumulation) duration.
  * `0x80` -- wait, VLQ ticks (48 ticks to a quarter note in the games
    this has been checked against).
  * `0x81` -- program change, selecting an instrument by ID out of the
    paired RBNK.
  * `0x88` -- start a new track: track number byte + a 24-bit offset.
  * `0x89`/`0x8A` -- jump / call subroutine, each a 24-bit offset.
  * `0xFF` -- end of track.
  * `0xA0`-`0xA5` -- prefix bytes that modify the *next* event: random
    range, variable substitution, conditional execution, time-based fades.
  * `0xF0`-prefixed extended opcodes (`F0 AA BB CCCC`) -- variable
    assignment/arithmetic (`0x80`-`0x8B`) and comparisons (`0x90`-`0x95`)
    for the format's small scripting layer, used for things like
    randomized fills or state-driven music switches.

  A full opcode table is out of scope for a container-level `.ksy` and
  would need its own dedicated bytecode grammar; see lib-sequence.h and
  community disassemblers (e.g. `kitlith/rseq_rs`) for the complete set.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"RSEQ"', '"CSEQ"', '"FSEQ"', '"SSEQ"']
  - id: bom
    type: u2
    doc: Byte-order mark; only meaningful for FSEQ (0xFEFF = big-endian).
  - id: version
    type: u2
    doc: 0x0100 in Wii RSEQ files; the container generation is otherwise identified by `magic` alone.
  - id: file_size
    type: u4
  - id: body
    type:
      switch-on: magic
      cases:
        '"RSEQ"': rseq_legacy_body
        _: block_table_body
types:
  rseq_legacy_body:
    doc: |
      Legacy Wii RSEQ layout (version 0x0100): direct block offsets, both
      relative to the file start (not to this body). No count or type tag
      is needed since DATA and LABL are always both present and always in
      this fixed order.
    seq:
      - id: data_off
        type: u4be
        doc: Absolute file offset of the DATA block's `_DATA_`-style magic.
      - id: data_size
        type: u4be
      - id: labl_off
        type: u4be
        doc: |
          Absolute file offset of the LABL block. LABL holds named entry
          points into DATA -- e.g. a "loop start" or per-song-section
          label a game jumps to -- as (offset, name) pairs; the label
          text itself is only useful to a human or a disassembler, not to
          the sequence player at runtime.
      - id: labl_size
        type: u4be
  block_table_body:
    doc: |
      Newer layout shared by CSEQ/FSEQ/SSEQ: a reference table of
      {type, offset, size} entries, each type 0x5000 = DATA (code)
      or 0x5001 = LABL (labels). Functionally the same two blocks as
      RSEQ's `rseq_legacy_body`, just generalized into the same typed
      reference-table idiom `nw4r/brstm.ksy`'s FSTM/CSTM side and
      `nw4c/bxwav.ksy` use elsewhere in the NW4C generation, instead of
      RSEQ's two bespoke offset/size pairs.
    seq:
      - id: num_blocks
        type: u2
      - id: unknown_02
        size: 2
      - id: blocks
        type: block_ref
        repeat: expr
        repeat-expr: num_blocks
  block_ref:
    seq:
      - id: block_type
        type: u2
        enum: block_type_t
      - id: unknown_02
        size: 2
      - id: offset
        type: u4
      - id: size
        type: u4
enums:
  block_type_t:
    0x5000: data
    0x5001: labl
