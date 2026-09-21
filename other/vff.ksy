meta:
  id: vff
  endian: be
  title: Nintendo VFF (PrFILE2 Virtual FAT volume)
doc: |
  Nintendo "VFF " PrFILE2 (eSOL) Virtual FAT volume, per lib-vff.c.
  Wii channels and save data use this to hold a small FAT12/FAT16
  filesystem inside a single file. Only the 0x20-byte wrapper header
  is modeled here; the FAT tables, root directory and clusters that
  follow are a standard FAT12/16 filesystem, not modeled further.
seq:
  - id: magic
    contents: "VFF "
  - id: bom
    type: u2
    doc: 0xfeff = big-endian body, 0xfffe = little-endian body.
  - id: unknown_06
    type: u2
  - id: volume_size
    type: u4
  - id: cluster_size_units
    type: u2
    doc: Cluster size in units of 16 bytes.
  - id: padding
    size: 0x20 - 0x0e
