meta:
  id: jarc
  file-extension: arc
  application: "\"jARC\"/\"JARC\" archive container (with optional \"jCMP\"/\"JCMP\" LZ wrapper)"
  endian: be
doc: |
  Generic "jARC"/"JARC" archive container, as recovered heuristically by
  `ScanJARC()` in `lib-jarc.c` of Wiimms SZS Tools. The format has no
  public specification; the source documents its layout only through the
  recovery heuristics it applies, in order:

    1. If the stream starts with "jCMP"/"JCMP", it is a whole-file LZ
       wrapper (`DecodeJCMP()`); the real container follows after
       decompression.
    2. If what follows does not start with "jARC"/"JARC", the whole
       (decompressed) blob is treated as a single opaque member (its type
       is guessed from magic bytes: jMDL/jTEX/jIMG/jMOT/jMSG/jCLT/jEFC/
       jSCN/jWAT/jSND/jCMP/jARC/FRES/SARC/Yaz0).
    3. Otherwise, a file count is read as a big-endian *or* little-endian
       `u32` at offset 0x08 (falling back to offset 0x04 for some
       variants) -- whichever reading yields a sane count is used to fix
       the archive's byte order for the rest of the parse.
    4. A table-of-contents offset is read as a `u32` at offset 0x0c
       (defaulting to 0x10 if it looks invalid); the TOC itself is an
       array of `{offset, size}` `u32` pairs (8 bytes per entry; some
       variants apparently use 16-byte entries and are handled as a
       fallback in the source, not modeled here).
    5. If no consistent count/TOC is found at all, the source instead
       scans the whole blob for embedded member magics (jMDL/jTEX/...)
       every 4 bytes and reconstructs implicit chunk boundaries; that
       last-resort heuristic is a moving byte-scan rather than a fixed
       binary layout and is not modeled here.

  This `.ksy` models the common, well-formed case (step 3/4): a "jARC"
  magic, a file count and TOC offset in the header, and a flat TOC of
  offset/size pairs pointing at member data. Byte order (big vs. little
  endian) is a per-file runtime decision in the source; this definition
  assumes the common big-endian case matching most other Wii formats in
  this repository.
seq:
  - id: magic
    contents: "jARC"
    doc: |
      4-byte tag; the source also accepts the all-uppercase spelling
      "JARC" (not modeled as a separate magic here).
  - id: unknown_04
    size: 4
  - id: num_files
    type: u4
    doc: Number of TOC entries.
  - id: toc_offset
    type: u4
    doc: |
      Absolute file offset of the TOC; the source defaults to 0x10 if
      this value looks out of range.
instances:
  toc:
    pos: toc_offset
    type: toc_entry
    repeat: expr
    repeat-expr: num_files
types:
  toc_entry:
    seq:
      - id: ofs_data
        type: u4
      - id: len_data
        type: u4
    instances:
      body:
        io: _root._io
        pos: ofs_data
        size: len_data
        if: ofs_data != 0 and len_data != 0
