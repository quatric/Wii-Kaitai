meta:
  id: brfna
  file-extension: brfna
  endian: be
  imports:
    - brfnt
  title: NW4R BRFNA archived bitmap font
doc: |
  An "archived" sibling of BRFNT (magic `RFNT` either way -- BRFNA files
  differ only in that their `TGLP` texture sheets may be stored
  compressed, flagged by bit 0x8000 of `sheet_format`). The four-section
  layout (`FINF`/`TGLP`/`CWDH`/`CMAP`) is otherwise identical to BRFNT;
  see `nw4r/brfnt.ksy` for that shared structure and `lib-brfna.c` for
  the compressed-sheet codec (RE'd from `nw4r_fontcvtr.exe`, no written
  spec exists).

  A compressed `TGLP` sheet is a 4-byte-BE-size-prefixed chunk: the first
  4 bytes are itself a little-endian word whose top 3 bytes give the
  decompressed byte target and whose low byte's low nibble selects the
  codec (0x10 LZSS, 0x20 a self-contained Huffman-style bit-walk, 0x30
  RLE; 0x80 -- a delta/predictive table encoder -- is never observed on
  real pixel data and unsupported). This definition exposes the
  compressed sheet bytes as-is; decoding them is `lib-brfna.c`'s job, not
  Kaitai's.
seq:
  - id: header
    type: brfnt
