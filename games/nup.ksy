meta:
  id: nup
  title: NUP "NX Package" container
  file-extension: nup
  endian: le
doc: |
  Open container for decrypted Nintendo Switch / Switch 2 dumps: base program,
  updates and add-on content as plain ExeFS/RomFS trees; each file is raw or one
  zstd frame. Layout: 0x80-byte superblock, a table of contents (packages,
  directories, files, child slots, string pool) hashed with SHA-256, then
  16-byte-aligned extents. Field-level layout lives in lib-nup.c.
seq:
  - id: magic
    contents: ["NUP", 1]
  - id: superblock_rest
    size: 0x80 - 4
  - id: rest
    size-eos: true
