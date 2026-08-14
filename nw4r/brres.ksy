meta:
  id: brres
  file-extension: brres
  endian: be
  imports:
    - mdl0
    - tex0
    - plt0
    - brres_sub_header
  title: NW4R BRRES resource archive
doc: |
  The NintendoWare for Revolution archive that holds a Wii game's models,
  textures, palettes and animations. Its own name for itself is `bres`;
  `.brres` is the file extension the SDK tools use.

  The layout is two levels of the same structure. A single root section
  holds one resource group whose entries are *folders* -- `3DModels(NW4R)`,
  `Textures(NW4R)`, `Palettes(NW4R)`, `AnmChr(NW4R)` and so on. Each of
  those points at another resource group whose entries are the actual
  sub-files. Both levels use the identical 16-byte entry, and in both the
  entry's two offsets are measured **from the start of the group that
  contains the entry**, not from the file.

  Sub-files sit back-to-back after the groups, and each one's header
  carries its own length, so the archive can be walked either through the
  groups or linearly.
seq:
  - id: magic
    contents: "bres"
  - id: bom
    type: u2
    doc: |
      Byte-order mark: 0xfeff read big-endian means the rest of the file is
      big-endian, which is what every Wii BRRES is. A 0xfffe here would
      flip the whole file; this definition assumes the Wii case.
  - id: version
    type: u2
  - id: len_file
    type: u4
    doc: Total archive size; equal to the real file length in every sample checked.
  - id: ofs_root
    type: u2
    doc: Offset to the `root` section, 0x10 in practice (immediately after this header).
  - id: num_sections
    type: u2
    doc: |
      Number of sub-files across every folder, plus one for the root
      group itself. Checked against a walk of the group tree on all
      eleven sample archives, from a single-model file (1 sub-file,
      reports 2) to a 295-sub-file item pack (reports 296); it never
      counts folders.
instances:
  root:
    pos: ofs_root
    type: root_section
types:
  root_section:
    doc: |
      A four-byte tag, the size of the whole root block (groups included),
      and then the folder-level resource group.
    seq:
      - id: magic
        contents: "root"
      - id: len_section
        type: u4
      - id: folders
        type: resource_group(_root.ofs_root + 8, true)

  resource_group:
    doc: |
      A radix-tree index. `num_entries` counts the real entries only: the
      group physically stores `num_entries + 1` of them because entry 0 is
      a sentinel root node (`id` 0xffff, both offsets zero) that exists to
      anchor the tree walk. Nothing needs the tree to read an archive --
      the entries can simply be enumerated -- so `id`, `idx_left` and
      `idx_right` are only meaningful to code doing lookups by name.
    params:
      - id: base_ofs
        type: u4
        doc: Absolute offset of this group; every entry offset is relative to it.
      - id: is_folder_list
        type: bool
        doc: True for the root group, whose entries point at further groups.
    seq:
      - id: len_group
        type: u4
        doc: |
          Size of the group header plus its entries: 8 + 16 * (num_entries + 1).
          It does not cover the names or the sub-file data, which live outside.
      - id: num_entries
        type: u4
      - id: entries
        type: resource_entry(base_ofs, is_folder_list)
        repeat: expr
        repeat-expr: num_entries + 1

  resource_entry:
    params:
      - id: base_ofs
        type: u4
      - id: is_folder
        type: bool
    seq:
      - id: id
        type: u2
        doc: Radix-tree search key (bit index); 0xffff on the sentinel entry.
      - id: reserved
        type: u2
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
        doc: Indices of the two child entries within this same group.
      - id: ofs_name
        type: u4
        doc: Offset from `base_ofs` to this entry's name in the string pool.
      - id: ofs_data
        type: u4
        doc: Offset from `base_ofs` to the child group or the sub-file.
    instances:
      name:
        pos: base_ofs + ofs_name - 4
        type: pooled_string
        if: ofs_name != 0
        doc: |
          The pool stores a u4 character count immediately before the text
          and a NUL after it, so the length lives four bytes below the
          offset the entry points at.
      folder:
        type: resource_group(base_ofs + ofs_data, false)
        pos: base_ofs + ofs_data
        if: is_folder and ofs_data != 0
      len_sub_file:
        pos: base_ofs + ofs_data + 4
        type: u4
        if: not is_folder and ofs_data != 0
      magic_sub_file:
        pos: base_ofs + ofs_data
        type: str
        size: 4
        encoding: ISO-8859-1
        if: not is_folder and ofs_data != 0
        doc: |
          Decoded as Latin-1 rather than ASCII on purpose. A folder does
          not have to hold BRRES sub-files: retail archives carry an
          `External` folder whose members are whole foreign files -- a
          `.brseq` sequence (magic `RSEQ`) alongside a `.bfs` whose first
          bytes are `01 b3 00 00`. Latin-1 maps every byte, so probing the
          tag cannot throw on those.
      file:
        pos: base_ofs + ofs_data
        size-eos: true
        if: not is_folder and ofs_data != 0
        type:
          switch-on: magic_sub_file
          cases:
            '"MDL0"': mdl0
            '"TEX0"': tex0
            '"PLT0"': plt0
            '"CHR0"': brres_sub_header
            '"CLR0"': brres_sub_header
            '"PAT0"': brres_sub_header
            '"SRT0"': brres_sub_header
            '"SHP0"': brres_sub_header
            '"VIS0"': brres_sub_header
            '"SCN0"': brres_sub_header
        doc: |
          Sub-files whose own definition exists are parsed in full. The
          animation types are read down to the common 16-byte header,
          which is enough to get their size and version. Anything else --
          including the foreign files in an `External` folder, which are
          not BRSUBs at all -- is left as raw bytes, reachable through
          `_raw_file`. There is deliberately no catch-all case: parsing a
          `.bfs` as if it had a BRSUB header would invent a magic, a size
          and a version out of its first sixteen bytes.

          The substream deliberately runs from the sub-file's start to the
          end of the archive rather than stopping at `len_sub_file`. Every
          offset inside a sub-file is measured from that sub-file's start,
          but the *strings* they point at live in one pool shared by the
          whole archive, past the last sub-file. Cutting the stream at
          `len_sub_file` would parse the structure fine and silently lose
          every name. `len_sub_file` is still the true size, and is what a
          linear walk should step by.

  pooled_string:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        size: len_name
        encoding: ASCII
