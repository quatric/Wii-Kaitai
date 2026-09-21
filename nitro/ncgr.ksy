meta:
  id: ncgr
  endian: le
  title: Nintendo DS "Nitro" character graphics (NCGR tile data)
doc: |
  Nintendo DS NCGR ("RGCN") tile pixel container, as read by
  ScanNitroNCGR() in lib-nitro.c. A generic NNS G2D RIFF-style
  container: outer "RGCN" header wrapping one "RAHC" chunk holding
  the raw tile pixel indices (not yet run through any palette).

  Chunk field offsets below are relative to the RAHC chunk, which
  itself always starts at absolute offset 0x10.
seq:
  - id: magic
    contents: "RGCN"
  - id: file_size
    type: u4
  - id: header_size
    type: u2
  - id: n_sections
    type: u2
  - id: rahc
    type: rahc_chunk
    size: file_size - 0x10
instances:
  bpp:
    value: 'rahc.depth == 3 ? 4 : rahc.depth == 4 ? 8 : 0'
    doc: 4bpp when depth==3, 8bpp when depth==4 (matches ScanNitroNCGR).
types:
  rahc_chunk:
    seq:
      - id: magic
        contents: "RAHC"
      - id: chunk_size
        type: u4
      - id: tile_height
        type: u2
        doc: In tiles (0xFFFF for 1D-mapped character data).
      - id: tile_width
        type: u2
        doc: In tiles; 0xFFFF or 0 means 1D-mapped/unspecified (num_x).
      - id: depth
        type: u4
        doc: 3 = 4bpp, 4 = 8bpp.
      - id: mapping
        type: u4
        doc: |
          Bit 0: 1 = 1D linear tile mapping, 0 = 2D sheet mapping.
          Bits 20-22: mapping boundary shift (0=32K .. 3=256K).
      - id: tile_data_size
        type: u4
      - id: tile_data_off
        type: u4
        doc: Relative to this RAHC chunk's start (add 8 per ScanNitroNCGR).
    instances:
      tile_data:
        pos: tile_data_off + 8
        size: tile_data_size
