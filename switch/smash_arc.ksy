meta:
  id: smash_arc
  endian: le
  title: Super Smash Bros. Ultimate ARC archive (data.arc)
doc: |
  Super Smash Bros. Ultimate top-level ARC container, per
  `smash_arc_header_t` and the table structs in lib-smash-arc.c
  (`ExtractSmashARC()`). Everything below the header is little-endian.

  `fs_offset` points at a V1 FileSystemHeader followed by the directory
  table, the directory-offset table (in two runs, sized
  `dir_offset_count1`/`dir_offset_count2`), a hash-folder lookup table
  (skipped here; 8 bytes per `hash_folder_count` entry, purpose not yet
  modeled) and the file-information / sub-file-information tables (also
  in two runs each). `search_offset` points at an optional
  SearchFileSystem table of folder/path hash lookups used to resolve
  full paths; nintoolbox's extractor does not need it to pull file data
  and only reads it when present.

  A directory's real byte range comes from its `dir_offset` entry
  (`offset_lo`/`offset_hi` combine into a 64-bit folder offset relative
  to the file-data area that begins after `file_section_offset`); a
  sub-file's absolute offset is `file_section_offset + folder_offset +
  sub_file.offset * 4`, and `sub_file.comp_size`/`decomp_size` describe
  a Zstd-compressed member (equal sizes mean stored, uncompressed).
seq:
  - id: magic
    contents: [0x10, 0x32, 0x54, 0x76, 0x98, 0xef, 0xcd, 0xab]
  - id: stream_section_offset
    type: u8
  - id: file_section_offset
    type: u8
  - id: shared_section_offset
    type: u8
  - id: fs_offset
    type: u8
  - id: search_offset
    type: u8
  - id: padding
    type: u8
instances:
  file_system:
    pos: fs_offset
    type: file_system_header_t
    if: fs_offset != 0
  search_file_system:
    pos: search_offset
    type: search_file_system_t
    if: search_offset != 0
types:
  hash_to_index_t:
    doc: 8-byte hash lookup entry; `length_and_index` packs an 8-bit length and a 24-bit index.
    seq:
      - id: hash
        type: u4
      - id: length_and_index
        type: u4
    instances:
      length:
        value: length_and_index & 0xff
      index:
        value: (length_and_index >> 8) & 0xffffff
  search_file_system_t:
    doc: SearchFileSystem table at `search_offset`; a 20-byte header plus 3 lookup arrays.
    seq:
      - id: size
        type: u8
      - id: folder_count
        type: u4
      - id: path_index_count
        type: u4
      - id: path_count
        type: u4
      - id: folder_lookup
        type: hash_to_index_t
        repeat: expr
        repeat-expr: folder_count
      - id: folders
        type: search_list_entry_t
        repeat: expr
        repeat-expr: folder_count
      - id: path_lookup
        type: hash_to_index_t
        repeat: expr
        repeat-expr: path_index_count
  search_list_entry_t:
    doc: 32-byte SearchListEntry (path, parent, file name and extension hash lookups).
    seq:
      - id: path
        type: hash_to_index_t
      - id: parent
        type: hash_to_index_t
      - id: file_name
        type: hash_to_index_t
      - id: ext
        type: hash_to_index_t
  file_system_header_t:
    doc: >-
      V1 FileSystemHeader (0x44 bytes) at `fs_offset`, followed by every
      table it counts, one after another with no gaps.
    seq:
      - id: table_size
        type: u4
      - id: folder_count
        type: u4
      - id: dir_offset_count1
        type: u4
      - id: file_information_count
        type: u4
      - id: sub_file_count1
        type: u4
      - id: unknown_14
        type: u4
      - id: hash_folder_count
        type: u4
      - id: unknown_1c
        type: u4
      - id: dir_offset_count2
        type: u4
      - id: sub_file_count2
        type: u4
      - id: unknown_28
        type: u4
        repeat: expr
        repeat-expr: 7
      - id: directories
        type: dir_list_v1_t
        repeat: expr
        repeat-expr: folder_count
      - id: dir_offsets
        type: dir_offset_v1_t
        repeat: expr
        repeat-expr: dir_offset_count1 + dir_offset_count2
      - id: hash_folder_lookup
        size: 8
        repeat: expr
        repeat-expr: hash_folder_count
        doc: Raw 8-byte entries; not yet decoded by the reference extractor.
      - id: file_infos
        type: file_info_v1_t
        repeat: expr
        repeat-expr: file_information_count
      - id: sub_files
        type: sub_file_info_v1_t
        repeat: expr
        repeat-expr: sub_file_count1 + sub_file_count2
  dir_list_v1_t:
    doc: 52-byte DirectoryList entry.
    seq:
      - id: full_path_hash
        type: u4
      - id: full_path_length_and_index
        type: u4
      - id: name_hash
        type: u4
      - id: name_hash_length
        type: u4
      - id: parent_folder_hash
        type: u4
      - id: parent_folder_hash_length
        type: u4
      - id: extra_dis_re
        type: u4
      - id: extra_dis_re_length
        type: u4
      - id: file_info_start_index
        type: s4
      - id: file_info_count
        type: s4
      - id: child_dir_start_index
        type: s4
      - id: child_dir_count
        type: s4
      - id: flags
        type: u4
  dir_offset_v1_t:
    doc: 28-byte DirectoryOffset entry giving a folder's data-area range.
    seq:
      - id: offset_lo
        type: u4
      - id: offset_hi
        type: u4
      - id: decomp_size
        type: u4
      - id: size
        type: u4
      - id: file_start_index
        type: u4
      - id: file_count
        type: u4
      - id: redirect_index
        type: u4
    instances:
      folder_offset:
        value: (offset_hi.as<u8> << 32) | offset_lo
        doc: 64-bit folder offset, relative to the start of the file-data area (after `file_section_offset`).
  file_info_v1_t:
    doc: 40-byte FileInformationV1 entry.
    seq:
      - id: path
        type: u4
      - id: directory_index
        type: u4
      - id: extension
        type: u4
      - id: file_table_flag
        type: u4
      - id: parent
        type: u4
      - id: unknown_14
        type: u4
      - id: hash2
        type: u4
      - id: unknown_1c
        type: u4
      - id: sub_file_index
        type: u4
      - id: flags
        type: u4
  sub_file_info_v1_t:
    doc: >-
      16-byte SubFileInfo entry. `offset` is a dword count relative to
      its folder's `folder_offset`, i.e. the real byte offset within
      the folder is `offset * 4`.
    seq:
      - id: offset
        type: u4
      - id: comp_size
        type: u4
        doc: Zstd-compressed size; equal to `decomp_size` for a stored (uncompressed) member.
      - id: decomp_size
        type: u4
      - id: flags
        type: u4
