meta:
  id: nlgdict
  endian: le
  file-extension:
    - dict
    - bin
  title: Next Level Games Dictionary Archive (LM2 / LM3 / Punch-Out!! Wii)
doc: |
  Next Level Games ".dict" archive, ported from `lib-nlgdict.c`/`.h`.
  Two magics select the variant:

    0x5824F3A9  LM2 / LM3 (Luigi's Mansion 2/3, Federation Force,
                 Mario Strikers: Battle League Football)
    0xA9F32458  Punch-Out!! Wii

  Endianness of the LM variant is ambiguous per-file (lib-nlgdict.c
  checks the magic both byte orders); this definition assumes
  little-endian, matching the more common on-disk form.

  The LM variant's structural block table depends on `ScanLM3Dict`/
  `ScanLM2Dict`/`ScanFedForceDict` (in `lib-nlg-lm.c`/`lib-fedforce.c`,
  not read for this definition) for the LM3/LM2/FedForce-detected cases.
  Only the legacy heuristic fallback used for Strikers-BLF/LM2HD/unknown
  LM files -- fully specified in `lib-nlgdict.c` itself -- is modelled
  here as `lm_legacy_body`. A companion `.data` file, when present,
  holds the actual block payloads named by the block table's offsets;
  it is a plain sequence of bytes with no header of its own.
seq:
  - id: magic
    type: u4
    doc: 0x5824F3A9 (LM2/LM3, this file's endianness) or 0xA9F32458 (Punch-Out!!).
  - id: body
    type:
      switch-on: magic
      cases:
        0xA9F32458: po_dict_body
        "_": lm_legacy_body
types:
  lm_legacy_body:
    doc: |
      Legacy heuristic layout for Strikers-BLF / LM2HD / unknown LM
      dictionaries (lib-nlgdict.c's non-variant-detected fallback path).
    instances:
      is_lm3:
        pos: 12
        type: u4
        doc: 0x78340300 marks LM3.
      is_fed:
        pos: 16
        type: u4
        doc: "0x297B947A marks Metroid Prime: Federation Force."
      is_strikers:
        pos: 0x40
        type: u4
        doc: "4247762216 (0xFD3A19A8) marks Mario Strikers: Battle League Football."
      compressed_flag:
        pos: 6
        type: u1
        doc: 1 means block payloads are zlib/zstd-compressed.
  po_dict_body:
    doc: Punch-Out!! Wii dictionary, fully specified in lib-nlgdict.c.
    seq:
      - id: unk1
        size: 12
      - id: num_files
        type: u4be
      - id: block_sizes
        type: u4be
        repeat: expr
        repeat-expr: 8
        doc: |
          8 fixed block sizes; block offsets are the running sum of the
          preceding sizes, starting at 0. The file table immediately
          follows the last block.
  po_file_entry:
    doc: 10 bytes, big-endian, one per file in the Punch-Out!! file table.
    seq:
      - id: chunk_flags
        type: u1
        doc: |
          Selects the block index: 0x12->0, 0x25->1, 2->2, 0x42->3, 3->0,
          else (flags>>4) if < 8.
      - id: unk1
        type: u1
      - id: chunk_type
        type: u2be
      - id: chunk_size
        type: u4be
      - id: chunk_offset
        type: u4be
        doc: Relative to the start of its resolved block.
  lm_dump_block:
    doc: |
      16-byte block-table entry used by the legacy heuristic path
      (offset, decompressed size, compressed size, then 4 bytes unused
      by lib-nlgdict.c).
    seq:
      - id: offset
        type: u4
      - id: decomp_size
        type: u4
      - id: comp_size
        type: u4
      - id: unk1
        type: u4
