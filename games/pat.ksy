meta:
  id: pat
  endian: be
  title: Mario Kart Wii PAT (pattern/lap animation) binary
doc: |
  Mario Kart Wii ".pat" pattern-animation file, ported from
  `pat_head_t`/`pat_s0_bhead_t`/`pat_s0_belem_t`/`pat_s0_sref_t`/
  `pat_s0_shead_t`/`pat_s0_selem_t` in lib-pat.h. The 16-byte
  `pat_head_t` sits at a fixed `PAT_HEAD_OFFSET` (0x2c) from the start
  of the file; everything before it (section-table/name-pool prelude)
  is not fully documented in the reference header and is left raw.
  Section-0 element offsets are relative to the `pat_s0_bhead_t` base
  they were read from, so they are exposed as raw values here rather
  than resolved instances.
seq:
  - id: prelude
    size: 0x2c
  - id: head
    type: pat_head_t
types:
  pat_head_t:
    seq:
      - id: unknown_00
        type: u2
      - id: unknown_02
        type: u2
      - id: n_frames
        type: u2
      - id: n_sect0
        type: u2
      - id: n_sect1
        type: u2
      - id: unknown_0a
        type: u2
      - id: unknown_0c
        type: u2
      - id: cyclic
        type: u2
  pat_s0_bhead_t:
    seq:
      - id: size
        type: u4
      - id: unknown_04
        type: u2
      - id: n_elem
        type: u2
      - id: unknown_08
        type: u2
      - id: unknown_0a
        type: u2
      - id: n_unknown
        type: u2
      - id: unknown_0e
        type: u2
      - id: unknown_10
        type: u2
      - id: unknown_12
        type: u2
      - id: unknown_14
        type: u2
      - id: unknown_16
        type: u2
      - id: elem
        type: pat_s0_belem_t
        repeat: expr
        repeat-expr: n_elem
  pat_s0_belem_t:
    seq:
      - id: unknown_00
        type: u2
      - id: unknown_02
        type: u2
      - id: unknown_04
        type: u2
      - id: unknown_06
        type: u2
      - id: offset_name
        type: u4
        doc: Relative to the owning pat_s0_bhead_t.
      - id: offset_strref
        type: u4
        doc: Relative to the owning pat_s0_bhead_t.
  pat_s0_sref_t:
    seq:
      - id: offset_name
        type: u4
      - id: unknown_04
        type: u2
      - id: type
        type: u2
        doc: Always 5 in retail MKW files.
      - id: offset_strlist
        type: u4
        doc: Relative to this header.
  pat_s0_shead_t:
    seq:
      - id: n_elem
        type: u2
      - id: unknown_02
        type: u2
      - id: factor
        type: f4
        doc: 1 / MAX(pat_s0_selem_t.time) across elem.
      - id: elem
        type: pat_s0_selem_t
        repeat: expr
        repeat-expr: n_elem
  pat_s0_selem_t:
    seq:
      - id: time
        type: f4
      - id: index
        type: u2
      - id: unknown_06
        type: u2
