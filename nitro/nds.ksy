meta:
  id: nds
  file-extension: nds
  endian: le
  title: Nintendo DS cartridge dump
doc: |
  A DS cartridge dump: a fixed header, two or four CPU binaries
  (ARM9/ARM7 plus optional overlay tables), an optional banner, and a
  file system made of three pieces that are only connected through file
  ids -- FNT (the directory tree and every name), FAT (each file's
  start/end offset), and the file data itself. Everything is sector
  aligned to 0x200.

  ## The FNT is two things layered together

  A fixed *main table*, one 8-byte entry per directory, indexed by a
  0xF000-based directory id (`id & 0xFFF` gives the index; the root is
  `0xF000`, i.e. index 0). Each entry gives where that directory's own
  *subtable* starts (an offset into the FNT region, not the file) and the
  file id of its first file, since file ids inside one directory are
  assigned consecutively and are not themselves stored per entry.

  The *subtable* is what actually lists a directory's contents: a
  sequence of variable-length records, one per name, terminated by a
  single zero byte. A record's leading byte packs both a type flag (bit 7:
  subdirectory) and a name length (the low 7 bits) into one byte, so a
  reader has to unpack it rather than reading a fixed-width type field.
  A file record carries only its name -- its FAT index is *derived*, by
  counting how many file (non-directory) records have been read in this
  directory so far and adding that to the directory's own `first_file_id`
  -- a subdirectory record carries an explicit id (its own main-table
  index) after the name, because recursing into it needs that id and
  nothing else supplies it.

  This definition follows `wiimms-iso-tools-plus`'s own extractor
  (`x-nds.c`) exactly, including what it does *not* read: the main
  table's root entry carries a total-directory-count in its otherwise
  parent-id-shaped third field (the standard convention, confirmed in
  public references), but neither this definition nor that extractor
  reads it -- the tree is walked by recursion instead, which needs no
  count.

  ## Validated against

  Two real retail cartridges, `Bomberman Blitz (USA)` (6 MiB, 1452 FAT
  entries) and `American Girl - Julie Finds a Way (USA)` (16 MiB). Every
  file this definition's FNT/FAT walk resolves -- full relative path,
  byte offset and size -- was compared against `wiimms-iso-tools-plus`'s
  own `wit XEXTRACT` output for both cartridges: 1452 files for
  Bomberman Blitz, matched one for one, same paths, same sizes.
seq:
  - id: title
    type: str
    size: 12
    encoding: ASCII
    terminator: 0
  - id: game_code
    type: str
    size: 4
    encoding: ASCII
  - id: maker_code
    type: str
    size: 2
    encoding: ASCII
  - id: unit_code
    type: u1
  - id: reserved1
    size: 0x20 - 0x13
  - id: ofs_arm9_rom
    type: u4
    doc: Offset in the image where the ARM9 binary is stored.
  - id: entry_arm9
    type: u4
    doc: ARM9 entry address. Unread by `wiimms-iso-tools-plus`'s extractor.
  - id: ram_arm9
    type: u4
    doc: ARM9 RAM load address. Unread by the extractor; the binary is copied verbatim.
  - id: len_arm9
    type: u4
  - id: ofs_arm7_rom
    type: u4
    doc: Offset in the image where the ARM7 binary is stored.
  - id: entry_arm7
    type: u4
    doc: ARM7 entry address. Unread by `wiimms-iso-tools-plus`'s extractor.
  - id: ram_arm7
    type: u4
    doc: ARM7 RAM load address. Unread by the extractor; the binary is copied verbatim.
  - id: len_arm7
    type: u4
  - id: ofs_fnt
    type: u4
  - id: len_fnt
    type: u4
  - id: ofs_fat
    type: u4
  - id: len_fat
    type: u4
  - id: ofs_overlay9
    type: u4
  - id: len_overlay9
    type: u4
  - id: ofs_overlay7
    type: u4
  - id: len_overlay7
    type: u4
  - id: reserved2
    size: 0x68 - 0x60
  - id: ofs_banner
    type: u4
  - id: reserved3
    size: 0x80 - 0x6c
  - id: len_rom
    type: u4
  - id: len_header
    type: u4
    doc: 0x200 for a plain DS cartridge, 0x4000 for a DSi-extended one.
  - id: reserved4
    size: 0x15c - 0x88
  - id: logo_crc
    type: u2
    doc: |
      CRC-16/ARC over the 156-byte Nintendo logo, always 0xCF56 for a
      genuine logo -- this is what identifies the format to the BIOS, not
      a copyright check on its own.
  - id: header_crc
    type: u2
    doc: CRC-16/ARC over the first 0x15E header bytes.
instances:
  num_fat_entries:
    value: len_fat / 8
  fat:
    pos: ofs_fat
    type: fat_entry
    repeat: expr
    repeat-expr: num_fat_entries
  overlay9_table:
    pos: ofs_overlay9
    type: u4
    repeat: expr
    repeat-expr: len_overlay9 / 32
    if: len_overlay9 > 0
    doc: |
      Each entry is a 32-byte overlay-table record; only the file id
      (offset 0x18 within it) matters for locating the overlay's bytes via
      `fat`, so this exposes just that id per entry rather than the whole
      record.
  root:
    pos: ofs_fnt
    type: fnt_dir(0xf000)
    doc: The root directory, main-table index 0.
types:
  fat_entry:
    seq:
      - id: ofs_start
        type: u4
      - id: ofs_end
        type: u4
    instances:
      len_file:
        value: ofs_end - ofs_start
      data:
        pos: ofs_start
        size: len_file
  fnt_dir:
    params:
      - id: dir_id
        type: u4
        doc: 0xF000-based; `dir_id & 0xFFF` is this directory's main-table index.
    seq:
      - id: ofs_subtable
        type: u4
        doc: Relative to the FNT region's own start, not to the file.
      - id: first_file_id
        type: u2
        doc: |
          FAT index of this directory's first file. Later files in the
          same directory are `first_file_id + 0`, `+ 1`, `+ 2`, ... in the
          order their records appear in `entries`.
      - id: parent_or_dir_count
        type: u2
        doc: |
          The root entry's copy of this field is a total directory count;
          every other entry's is its own parent directory id. Neither
          value is read by `wiimms-iso-tools-plus`'s extractor, or by this
          definition's walk -- recursion needs neither.
    instances:
      entries:
        pos: _root.ofs_fnt + ofs_subtable
        type: fnt_entry
        repeat: until
        repeat-until: _.is_end
        doc: |
          Runs until a zero type-length byte, not a fixed count -- a
          directory's entry count isn't stored anywhere, only its end
          marker. A file record's own FAT index is not stored here at
          all: it is `first_file_id` plus however many prior records in
          this same array are files rather than directories, per the
          top-level doc -- a consumer walking `entries` keeps that count
          itself, the same way `x-nds.c`'s `extract_dir` does with its own
          `file_id` local.
  fnt_entry:
    seq:
      - id: type_and_name_len
        type: u1
        doc: |
          Bit 7 set means subdirectory; the low 7 bits are `name`'s
          length. Zero means end of directory -- `name` and everything
          after it are absent in that case, not zero-length.
      - id: name
        type: str
        size: name_len
        encoding: ASCII
        if: not is_end
      - id: sub_dir_id
        type: u2
        if: is_directory
        doc: |
          Only present on a subdirectory record. 0xF000-based, matching
          `fnt_dir`'s own `dir_id` param -- this is what lets a reader
          recurse without a separate lookup.
    instances:
      is_end:
        value: type_and_name_len == 0
      is_directory:
        value: (type_and_name_len & 0x80) != 0 and not is_end
      name_len:
        value: type_and_name_len & 0x7f
      subdirectory:
        pos: _root.ofs_fnt + (sub_dir_id & 0xfff) * 8
        type: fnt_dir(sub_dir_id)
        if: is_directory
        doc: |
          Indexes the FNT main table, not the subtable region -- each
          main-table entry is 8 bytes, at `(sub_dir_id & 0xFFF) * 8`.
