meta:
  id: vff
  endian: be
  title: Nintendo VFF (PrFILE2 Virtual FAT volume)
doc: |
  Nintendo "VFF " PrFILE2 (eSOL) Virtual FAT volume, per lib-vff.c/.h.
  Wii channels and save data use this to hold a small FAT12/FAT16
  filesystem inside a single file, with the FAT boot sector left out
  (so a normal FAT tool cannot open one directly). The 0x20-byte
  wrapper header is followed by two copies of the FAT (each padded up
  to a cluster boundary), a fixed 0x1000-byte root directory, and then
  the data clusters themselves; cluster numbering starts at 2, so
  cluster N begins at `data_offset + (N-2)*cluster_size`. Everything
  below the header is little-endian regardless of the header's own
  big-endian fields and byte-order mark. FAT12 is used at or below
  0xff5 clusters, FAT16 above it; there is no FAT32 variant.
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
instances:
  cluster_size:
    value: cluster_size_units.as<u4> * 16
  cluster_count:
    value: volume_size / cluster_size
  fat_bits:
    value: 'cluster_count > 0xff5 ? 16 : 12'
    doc: FAT12 at or below 0xff5 clusters, else FAT16.
  raw_fat_size:
    value: 'fat_bits == 16 ? cluster_count * 2 : (cluster_count + 1) / 2 * 3'
  fat_size:
    value: (raw_fat_size + cluster_size - 1) & ~(cluster_size - 1)
    doc: raw_fat_size rounded up to a whole cluster.
  fat1:
    pos: 0x20
    size: fat_size
    doc: First FAT copy, little-endian regardless of the header's BOM.
  fat2:
    pos: 0x20 + fat_size
    size: fat_size
    doc: Second (redundant) FAT copy.
  root_dir:
    pos: 0x20 + 2 * fat_size
    type: dir_entry_t
    repeat: expr
    repeat-expr: 0x1000 / 32
    doc: Fixed 0x1000-byte root directory, 32 bytes per short (8.3) entry.
  data_offset:
    value: 0x20 + 2 * fat_size + 0x1000
    doc: Absolute offset of cluster 2, the first data cluster.
types:
  dir_entry_t:
    doc: >-
      Standard 32-byte FAT short directory entry. A first byte of 0x00
      marks the end of the directory and 0xe5 a deleted entry; `attr`
      bit 0x08 is a volume label and bit 0x0f (all of the low nibble)
      marks a VFAT long-name fragment, neither of which this project's
      reader expands.
    seq:
      - id: name
        type: str
        size: 8
        encoding: ASCII
      - id: ext
        type: str
        size: 3
        encoding: ASCII
      - id: attr
        type: u1
      - id: reserved
        type: u1
      - id: create_time_fine
        type: u1
      - id: create_time
        type: u2le
      - id: create_date
        type: u2le
      - id: access_date
        type: u2le
      - id: cluster_hi
        type: u2le
        doc: High 16 bits of the starting cluster (FAT32 only; unused here).
      - id: write_time
        type: u2le
      - id: write_date
        type: u2le
      - id: cluster_lo
        type: u2le
        doc: Starting cluster number of the entry's data.
      - id: size
        type: u4le
        doc: File size in bytes; 0 for a directory entry.
