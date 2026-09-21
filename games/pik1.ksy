meta:
  id: pik1
  title: Pikmin 1 (GameCube) MOD model, TXE texture and ARC/DIR archive
  endian: be
  license: CC0-1.0

doc: |
  Pikmin 1 (GameCube) asset formats. This file bundles the three related
  containers as separate types (no single root, since they are distinct
  files): `mod` (chunked model), `txe` (GX texture), and `dir` (the
  directory half of the ARC/DIR archive pair; ARC itself is just the raw
  payload bytes the DIR entries point into).

  Reference: nintoolbox project/src/lib-pik1.c/.h (IsPIKMOD/pk_walk,
  IsTXE/DecodeTXE_RGBA, ScanPIKARC/CreatePIKARC), re-implemented in that
  project from KillzXGaming/MdlConverter's GCNLibrary/Pikmin (MIT).

seq: []

types:
  mod:
    doc: |
      A stream of {s32 opcode, u32 size} chunk headers, each chunk padded so
      the next one starts on a 32-byte boundary. Starts with a Header chunk
      (opcode 0) at offset 0 and ends with an EOF chunk (opcode 0xffff).
      Chunk payload layouts beyond the generic "count + 32-byte-aligned
      pool" convention are not modeled here -- see lib-pik1.c's per-opcode
      readers for materials/joints/envelopes/meshes/etc.
    seq:
      - id: chunks
        type: chunk
        repeat: eos

  chunk:
    seq:
      - id: opcode
        type: s4
        enum: chunk_opcode
      - id: payload_size
        type: u4
      - id: payload
        size: payload_size
      - id: pad
        size: (-(8 + payload_size)) % 32
        doc: Padding to the next 32-byte boundary; absent for the final chunk.
        if: opcode != chunk_opcode::eof
    enums:
      chunk_opcode:
        0x0000: header
        0x0010: pos
        0x0011: nrm
        0x0012: nbt
        0x0013: col
        0x0018: uv0
        0x0019: uv1
        0x001a: uv2
        0x001b: uv3
        0x001c: uv4
        0x001d: uv5
        0x001e: uv6
        0x001f: uv7
        0x0020: tex
        0x0022: txattr
        0x0030: mat
        0x0040: skin
        0x0041: env
        0x0050: mesh
        0x0060: joint
        0x0061: jname
        0x0100: unknown_0x0100
        0x0110: unknown_0x0110
        0xffff: eof

  txe:
    doc: |
      GX texture with a 12-byte header; pixel data starts at the next
      32-byte boundary after the header (offset 32).
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: format
        type: u2
        enum: txe_format
      - id: reserved
        size: 2
      - id: declared_pixel_size
        type: u4
      - id: pad_to_32
        size: 20
      - id: pixel_data
        size: declared_pixel_size
    enums:
      txe_format:
        0: rgb565
        1: cmpr
        2: rgb5a3
        3: i4
        4: i8
        5: ia4
        6: ia8
        7: rgba32

  dir:
    doc: |
      The DIR half of an ARC/DIR pair. `file_size` is DIR's own recorded
      total size (informational only). Names are packed back-to-back
      immediately after the entry table, in entry order, each `name_len`
      bytes with no separator.
    seq:
      - id: file_size
        type: u4
      - id: num_entries
        type: u4
      - id: entries
        type: dir_entry
        repeat: expr
        repeat-expr: num_entries
    instances:
      name_table_start:
        value: 8 + num_entries * 12

  dir_entry:
    seq:
      - id: data_offset
        type: u4
        doc: Offset into the sibling ARC file.
      - id: data_size
        type: u4
      - id: name_len
        type: u4
