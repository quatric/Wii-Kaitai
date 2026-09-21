meta:
  id: bzip2
  file-extension:
    - wbz
    - wlz
  endian: be
  title: Wiimms WBZ/WLZ container around a BZIP2 stream
doc: |
  BZIP2 itself is Julian Seward's standard block-sorting compression
  format (http://www.bzip.org/1.0.5/bzip2-manual-1.0.5.html); Wiimms SZS
  Tools just link libbz2 to read/write it and add no data-layout of their
  own beyond the standard stream header that the tools' magic sniffers
  (IsBZ()/IsBZIP2() in lib-bzip2.c) check for: 4-byte magic "BZh", an
  ASCII compression-level digit '1'-'9', and the fixed per-block header
  magic "1AY&SY'" (0x314159265359, the digits of pi) that opens the first
  compressed block. That bare stream is what a plain .bz2 file contains,
  and is modeled here as `bzip2_stream`; the bit-packed Huffman/BWT block
  payload itself is not.

  Wiimms tools additionally define their own thin container around such
  a stream: WBZ (wbz_header_t in lib-szs.h, magic "WBZa") for bzip2, and
  WLZ (same struct, magic reused for LZMA) for LZMA. The container is a
  4-byte magic followed by a verbatim copy of the first 8 bytes of the
  *uncompressed* data -- so a magic-sniffer can identify the decompressed
  content's real format (e.g. spot a U8/BRRES/BREFF payload) without
  having to inflate anything -- and then the compressed stream itself.
seq:
  - id: magic
    contents: "WBZa"
  - id: uncompressed_magic
    size: 8
    doc: >
      Verbatim copy of the first 8 bytes of the decompressed payload,
      kept here purely so file-type detection doesn't need to decompress
      first.
  - id: compressed_payload
    type: bzip2_stream
    size-eos: true
    doc: The wrapped compressed stream (bzip2 for WBZ; for a WLZ file this is an LZMA stream instead and not modeled the same way).
types:
  bzip2_stream:
    seq:
      - id: bzh_magic
        contents: "BZh"
      - id: level
        type: str
        size: 1
        encoding: ASCII
        doc: Compression level as an ASCII digit, '1' (fastest/smallest blocks) to '9'.
      - id: block_magic
        contents: [0x31, 0x41, 0x59, 0x26, 0x53, 0x59]
        doc: >
          Fixed per-block magic "1AY&SY'" (0x314159265359); every
          compressed block in the stream starts with this. A stream ends
          with the alternate magic 0x177245385090 ("EOS") instead of
          another block magic; not modeled here since it only shows up
          after the last block, deep inside the bit-packed payload.
      - id: rest
        size-eos: true
        doc: Bit-packed Huffman/BWT-coded block data, not modeled.
