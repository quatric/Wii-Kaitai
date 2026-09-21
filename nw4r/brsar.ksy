meta:
  id: brsar
  file-extension: brsar
  endian: be
  title: NW4R RSAR Wii sound archive
doc: |
  The Wii `RSAR` sound-archive container -- the single file (typically
  named `sound_data.brsar` or similar) a retail Wii game ships all of its
  music, sound effects, banks and samples in. Community tools (BrawlBox /
  BrawlLib, later BrawlCrate, and vgmtrans' `RSARScanner`) reverse-engineered
  it independently from Super Smash Bros. Brawl and Mario Kart Wii, since
  Nintendo never published the layout. A fixed 0x40-byte header whose three
  payload blocks (`SYMB` the name/string table, `INFO` the sound/bank/group
  tables, `FILE` the raw payload blobs) are each an offset+size pair at a
  fixed slot in the header. Field layout verified against `lib-brsar.c`'s
  `UnpackBRSAR()`/`WriteRsarEnvelope()`, itself taken from vgmtrans'
  `RSARScanner.cpp`.

  The three blocks divide the archive by *kind of information*, not by
  file: `SYMB` is purely names (an FST-like radix-tree string pool used to
  look sounds/banks/groups up by name, mirroring the same trick BRRES's
  `resource_group` uses for model/texture names -- see `nw4r/brres.ksy`),
  `INFO` is purely parameters (per-sound volume/priority/pan/3D-audio
  settings, per-bank and per-group tables, player heap sizes), and `FILE`
  is purely raw bytes -- the embedded RSEQ/RBNK/RWAR/RWSD sub-files
  themselves, with no headers of their own beyond what those formats
  define. A game loads a whole *group* (a named bundle of sounds meant to
  be resident together, e.g. one stage's music and SFX) in one read, which
  is why `INFO`'s group table exists: it is the thing that turns "load
  group N" into a single contiguous span of `FILE` bytes. A sound that
  belongs to more than one group is physically duplicated in `FILE` once
  per group, rather than shared -- trading file size for load-time
  simplicity.

  The related Wii U `FSAR` and 3DS `CSAR` archives share the same three
  named blocks but wrap them in a BFSTM/BCSTM-style section table instead
  of this fixed header; `lib-brsar.c` explicitly documents that its
  handling of those two variants is an untested extrapolation rather than
  something verified against a real reader, so they are intentionally
  not modeled here.

  Only the SYMB/INFO/FILE envelope is modeled; the internal structure of
  the RSEQ/RBNK/RWAR/RWSD payloads those blocks describe is out of scope
  (`lib-brsar.c` itself treats most of it as opaque pass-through). Community
  tools that do decode INFO fully (BrawlBox/BrawlLib, vgmtrans) are the
  best available reference if that structure is ever added here.
seq:
  - id: magic
    contents: "RSAR"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 0x0104 in practice.
  - id: len_file
    type: u4
  - id: len_header
    type: u2
    doc: 0x40 in practice.
  - id: num_blocks
    type: u2
    doc: |
      Always 3 (SYMB, INFO, FILE), in that fixed order in every retail
      archive -- the three offset/size pairs below are positional rather
      than a real indexed table, so nothing here actually reads this count
      to decide how many pairs follow.
  - id: symb_off
    type: u4
  - id: len_symb
    type: u4
  - id: info_off
    type: u4
  - id: len_info
    type: u4
  - id: file_off
    type: u4
  - id: len_file_block
    type: u4
instances:
  symb:
    pos: symb_off
    size: len_symb
    type: block
  info:
    pos: info_off
    size: len_info
    type: block
  file:
    pos: file_off
    size: len_file_block
    type: block
types:
  block:
    doc: |
      Common `SYMB`/`INFO`/`FILE` block header: a 4-byte tag plus the
      size of the whole block (tag included), followed by block-specific
      content this definition does not decode further. All three blocks
      are padded so the *next* block starts on a 0x20 boundary relative to
      the file, which is why `len_symb`/`len_info`/`len_file_block` in the
      root header can run slightly past the meaningful content of `body`
      -- the padding bytes are included in the declared length rather than
      sitting outside it.
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: len_block
        type: u4
      - id: body
        size: len_block - 8
