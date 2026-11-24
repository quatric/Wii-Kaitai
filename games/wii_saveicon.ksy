meta:
  id: wii_saveicon
  title: Wii save banner / icon (.raw)
  file-extension: raw
  endian: be
doc: '"savebanner.raw" 192x64 (24576 bytes) and "saveicon<N>.raw" 48x48 (4608 bytes), RGB5A3 in GX 4x4 tiling, no header.'
seq:
  - id: pixels
    type: u2
    repeat: eos
