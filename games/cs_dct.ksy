meta:
  id: cs_dct
  file-extension: dct
  endian: le
  title: Chicken Shoot stage/graphics archive (Wii/PC)
doc: |
  `.dct` stage and graphics archive used by Chicken Shoot (Wii/PC). There
  is no ASCII magic; the format is identified structurally by a fixed
  `version` field of 5 plus sane bounds on the record counts that follow.

  Every compressed region (background pixels, per-region auxiliary data,
  animation frames, the main and auxiliary object parameter tables) uses
  the same small proprietary LZ scheme: a stream of 2-byte commands
  `(b0, b1)` where `b0 == 0` means "b1 literal bytes follow in the
  stream" and any other `b0` means "copy b1 bytes from
  `table[b0] = (b0*b0)/2` bytes back" (with `table[1]` fixed at 1,
  overriding the formula). This structure only frames the compressed
  byte ranges (`body`) -- decompressing them is out of scope for a
  Kaitai spec and is left to application code.

  Background, animation and object data are variable-length and depend on
  per-record flags (`has_palette`, `aux_flag`, the animation flags byte,
  and the object dimensions), which is more branching than a straight
  `seq` can express cleanly; only the fixed-size header and per-record
  tables are modeled here. Consumers should treat `background_records`
  and `animation_records` as the entry point and walk the variable
  payloads that follow them by hand, mirroring `lib-cs-dct.c`.
seq:
  - id: version
    type: u2
    doc: Always 5 in every known sample; this is what identifies the format.
  - id: num_bgr
    type: u2
    doc: Number of background records.
  - id: num_anim
    type: u2
    doc: Number of animation sprite records.
  - id: num_obj
    type: u2
    doc: Number of objects in the main parameter table.
  - id: h4
    type: u2
    doc: Auxiliary object table width (chunk grid).
  - id: h5
    type: u2
    doc: Auxiliary object table height (chunk grid).
  - id: h6
    type: u2
  - id: h7
    type: u2
  - id: background_records
    type: background_record
    repeat: expr
    repeat-expr: num_bgr
    doc: |
      Fixed-size headers only. The variable background pixel/palette/
      auxiliary data that follows each record in the file is not modeled
      here; see the format doc above.
types:
  background_record:
    seq:
      - id: unk0
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: flags
        type: u2
        doc: Bit 0 set means compressed pixel data follows (when width*height > 0).
      - id: has_palette
        type: u2
        doc: Nonzero means a 512-byte big-endian RGB555 palette follows.
      - id: aux_flag
        type: u2
        doc: Nonzero means a length-prefixed auxiliary compressed block follows.
      - id: unk6
        type: u2
      - id: unk7
        type: u2
