meta:
  id: kylotonn_chunks
  title: Kylotonn engine chunk stream (.mdl / .snd / .txc / .vid)
  endian: le
doc: |
  Cocoto Festival. After a short prefix (u32 0/1 for .txc and .snd, or
  {u16, u16, name} for .mdl / .vid) the file is a list of little-endian chunks
  {tag, u32 size including the 8 header bytes}. .snd: NAME FREQ STER SIZE CSZE
  SAMP (SAMP = DSP header + ADPCM with 16-bit words byte-swapped). .txc: BTCH
  {TYPE SIZE MTRD...}; PACK 5 = LZ + Huffman. .mdl: FLAG DYNL CYLD SKIN{...}
  with MODL blocks. .vid: SIZX SIZY PACK NBFR FSEC SFRE SAMP STER SCRU then one
  VIDE chunk per frame.
seq:
  - id: prefix
    type: u4
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size_with_header
        type: u4
      - id: body
        size: size_with_header - 8
