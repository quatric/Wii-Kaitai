meta:
  id: ztab
  endian: be
  title: Camelot Archive Table (.ztab)
doc: |
  Camelot Archive Table used by Camelot-engine games. A ZTAB file has an
  8-byte header, a fixed 16-byte descriptor per member, and payloads addressed
  by absolute file offsets. It carries no filenames; nintoolbox extracts
  members as `entry_NNNN_flags_XXXXXXXX.bin` so that the descriptor flags can
  survive a round trip.

  nintoolbox requires a non-zero count no larger than 100,000 and a complete
  descriptor table. It treats `offset` as absolute, clamps a member whose
  declared range runs past EOF, and skips an entry that starts at or beyond
  EOF. The canonical writer sorts inputs, derives `flags` from `flags_` in a
  basename when present, leaves `unknown_0c` zero, and aligns the first payload
  and every following payload to 16 bytes.
seq:
  - id: magic
    contents: "ZTAB"
    doc: ASCII signature `ZTAB` (0x5a544142).
  - id: num_entries
    type: u4
    doc: Number of 16-byte descriptors immediately following the header.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
types:
  entry_t:
    seq:
      - id: flags
        type: u4
        doc: Per-member flags with format-specific meaning not established by
          nintoolbox. The writer preserves a hexadecimal `flags_` suffix from
          extracted filenames.
      - id: offset
        type: u4
        doc: Absolute byte offset of this member's stored payload.
      - id: size
        type: u4
        doc: Declared payload length before the reader's EOF clamping.
      - id: unknown_0c
        type: u4
        doc: Unknown descriptor word. The canonical writer emits zero.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
        doc: Stored member bytes selected by the descriptor's absolute range.
