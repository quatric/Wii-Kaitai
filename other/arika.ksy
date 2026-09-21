meta:
  id: arika
  file-extension: dat
  endian: le
  title: Arika INFO.DAT directory (DS/DSi)
doc: |
  The directory half of Arika's "rom:\INFO.DAT" / "rom:\GAME.DAT" pair
  (Dr. Mario Online Rx/Express, the original DS Endless Ocean, and
  Endless Ocean: Blue World's own non-encrypted *ARK variant). This .ksy
  covers INFO.DAT only, after decryption -- GAME.DAT is just raw member
  bytes addressed by `entries[i].byte_offset`/`entries[i].len_decompressed`
  from this table and is not itself structured (each member is either
  stored raw or ALZ1/ZALZ-compressed; see lib-arika.c's DecodeALZ1).

  Bytes [0x10, EOF) are XOR/rotate/subtract-obfuscated using the 16-byte
  title/key at the very start whenever that key's first byte is nonzero;
  a title starting with a NUL byte (Blue World's "*ARK" variant included)
  means the file was never encrypted. That transform is a byte cipher,
  not a structural field, so it is not modeled here -- feed this type
  already-decrypted bytes (see DecryptArikaInfo).
seq:
  - id: title
    size: 16
    doc: |
      Doubles as the decryption key; a title whose first byte is 0x00
      means the file is stored unencrypted.
  - id: reserved
    size: 20
  - id: sector_size
    type: u4
    doc: 0 means the real sector size is 0x800.
  - id: unknown
    type: u4
    doc: Reportedly a version field.
  - id: num_entries
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: name
        type: strz
        encoding: ASCII
        size: 32
        doc: Zero-padded; an all-zero name marks an unused directory slot.
      - id: len_stored
        type: u4
        doc: Byte size in GAME.DAT; equals `len_decompressed` when stored raw.
      - id: ofs_sectors
        type: u4
        doc: Offset into GAME.DAT, in `sector_size` units.
      - id: len_sectors
        type: u4
        doc: Size in GAME.DAT, in sector units; informational only.
      - id: len_decompressed
        type: u4
    instances:
      real_sector_size:
        value: '_root.sector_size == 0 ? 0x800 : _root.sector_size'
      byte_offset:
        value: ofs_sectors * real_sector_size
      is_compressed:
        value: len_stored != len_decompressed
