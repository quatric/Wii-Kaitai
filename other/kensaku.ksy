meta:
  id: kensaku
  file-extension: res
  application: "And-Kensaku \"Pres\" archive (Nintendo DS \"Kanji Sonomama Rakubiki Jiten\" family)"
  endian: le
doc: |
  CyberConnect2 "Pres" archive, as decoded (once already decompressed
  from the whole-stream Nintendo LZ77 wrapper used by the ".rz" files) by
  `ScanKensakuRes()`/`ScanKensakuPres()` in `lib-kensaku.c` of Wiimms SZS
  Tools. Ported from Luigi Auriemma's `and_kensaku.bms`. This `.ksy`
  models the already-decompressed "Pres" blob (i.e. the ".res" variant);
  the compressed ".rz" container is just that same blob run through
  Nintendo LZ77 type 0x10 or 0x11 and is not separately modeled.

  Layout: a fixed 0x80-byte header (only the "Pres" magic and, for most
  archives, a `u32` at offset 0x60 giving the end of the entry table are
  meaningful; the rest is unparsed by the source), followed by a table of
  0x20-byte entries starting right at offset 0x80, followed by a trailing
  string/name pool and the member data itself.

  Determining where the entry table ends is unreliable: most archives
  give it directly at header offset 0x60, a few leave that zero and rely
  on the first member's data offset (the `u32` at file offset 0x80)
  coinciding with the table's end instead, and the source's last resort
  is to keep reading 0x20-byte records while their reserved trailing 16
  bytes stay zero. This `.ksy` exposes both header fields but leaves the
  actual entry-count decision to the reader/consumer, matching the
  source's own multi-heuristic approach.
seq:
  - id: magic
    contents: "Pres"
  - id: header_rest
    size: 0x60 - 4
    doc: Unparsed header fields (0x04..0x5f); layout not documented by the source.
  - id: table_end_hint
    type: u4
    doc: |
      Usually the absolute end offset of the entry table (a multiple of
      0x20 past 0x80). Zero for a few archives (see class doc); those
      instead rely on the first entry's `ofs_data` coinciding with the
      table's end.
  - id: header_tail
    size: 0x80 - 0x64
    doc: Remaining unparsed header bytes up to the fixed 0x80-byte header size.
instances:
  first_entry:
    pos: 0x80
    type: entry
    doc: First 0x20-byte entry of the table; further entries follow contiguously.
types:
  entry:
    seq:
      - id: ofs_data
        type: u4
        doc: Absolute offset of the member's data; 0 marks an unused/directory slot.
      - id: len_data
        type: u4
      - id: ofs_name_desc
        type: u4
        doc: Offset of a 3-`u32` name descriptor (name, extension, folder string offsets).
      - id: num_name_elements
        type: u4
        doc: How many of the 3 name-descriptor fields are actually used (1..3).
      - id: reserved
        size: 16
        doc: |
          Always zero for a real entry; the source stops walking the
          table as soon as it sees a non-zero byte here.
    instances:
      body:
        io: _root._io
        pos: ofs_data
        size: len_data
        if: ofs_data != 0
      name_desc:
        io: _root._io
        pos: ofs_name_desc
        type: name_descriptor
        if: ofs_name_desc != 0
  name_descriptor:
    seq:
      - id: ofs_name
        type: u4
      - id: ofs_ext
        type: u4
      - id: ofs_folder
        type: u4
    instances:
      name:
        io: _root._io
        pos: ofs_name
        type: strz
        encoding: ASCII
        if: ofs_name != 0
      ext:
        io: _root._io
        pos: ofs_ext
        type: strz
        encoding: ASCII
        if: ofs_ext != 0
      folder:
        io: _root._io
        pos: ofs_folder
        type: strz
        encoding: ASCII
        if: ofs_folder != 0
