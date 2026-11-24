meta:
  id: cvm
  title: CRI CVM image (Sonic Riders Shooting Star Story)
  file-extension: cvm
doc: |
  {"CVMH", ... "ROFSROFSBLD Ver.x" header} padded to 0x1800, followed by a plain
  ISO9660 ("CRI ROFS") image. The ISO base is where "CD001" appears at base +
  0x8001 (0x1800 for CVM, 0 for a bare ISO named *.cvm).
seq:
  - id: magic
    contents: CVMH
  - id: header
    size: 0x1800 - 4
  - id: iso
    size-eos: true
