meta:
  id: harmonix_ark
  title: Harmonix Ark archive header (.hdr) -- Guitar Hero / Rock Band
  file-extension: hdr
  endian: le
doc: |
  Harmonix "Ark" archives: a header (`*.hdr`) plus one or more data parts
  (`<stem>_0.ark`, `<stem>_1.ark`, ...). Used by Guitar Hero 1/2, Rock Band 1-3,
  The Beatles: Rock Band, AC/DC Live: Rock Band, Green Day: Rock Band and Lego
  Rock Band. Documented in code by PikminGuts92's Mackiloha / ArkHelper;
  nintoolbox is an independent C reimplementation, checked against the Wii
  AC/DC Live: Rock Band Track Pack disc, where the entry sizes of all 3418
  members add up to the ark's length to the byte.

  **This definition describes the decrypted header** (little-endian on Wii).
  Header encryption: if the first `u4` is not a known version (2..7, 9, 10) it is
  a *key*, and every following byte is XORed with the low byte of a Lehmer /
  Park-Miller generator -- `key = key * 16807 mod 2^31 - 1` computed with
  Schrage's method as `(k - (k / 127773) * 127773) * 16807 - (k / 127773) * 2836`,
  adding `0x7fffffff` when `<= 0` -- stepped once per byte. If the version after
  that is still unknown it is stored complemented and the rest of the header
  needs one more `^ 0xff`. The key word is dropped so the version comes first.

  Version-dependent parts:

  * `version >= 6` -- a block of `n * 16` hash bytes precedes the part list;
  * part sizes are `u4` each, but `u8` each in version 4 (a "broken" v4 that is
    really v3/v5 is detected when the last 64-bit size exceeds 32 bits, then they
    are re-read as `u4`; the broken case is not expressible here);
  * `version >= 5` (or broken v4) -- length-prefixed part names, ignored (parts
    are `<hdr stem>_<i>.ark`);
  * `6 <= version <= 9` -- `n * 4` hash bytes;
  * `version >= 7` -- file lists, skipped;
  * `version <= 7` -- a string blob, an index table and the entries (offset is
    `u8` for `version >= 4`, `u4` below); the indexes go through the table;
  * `version >= 9` -- entries carry their full path; then a hash table.

  Offsets are global across the parts; a member never straddles two parts. The
  data parts themselves are unframed.
seq:
  - id: version
    type: u4
    doc: 2..7, 9 or 10 in a decrypted header.
  - id: pre_hashes
    type: hash_block16
    if: version >= 6
  - id: ark_file_count
    type: u4
  - id: num_part_sizes
    type: u4
    doc: Equals the part count.
  - id: part_sizes_u8
    type: u8
    repeat: expr
    repeat-expr: num_part_sizes
    if: version == 4
  - id: part_sizes_u4
    type: u4
    repeat: expr
    repeat-expr: num_part_sizes
    if: version != 4
  - id: part_names
    type: counted_strings
    if: version >= 5
  - id: hashes_a
    type: hash_block4
    if: version >= 6 and version <= 9
  - id: file_lists
    type: file_lists
    if: version >= 7
  - id: legacy
    type: legacy_table
    if: version <= 7
  - id: modern
    type: modern_table
    if: version >= 9
types:
  lstring:
    seq:
      - id: length
        type: u4
      - id: value
        size: length
  counted_strings:
    seq:
      - id: count
        type: u4
      - id: items
        type: lstring
        repeat: expr
        repeat-expr: count
  hash_block16:
    seq:
      - id: count
        type: u4
      - id: hashes
        size: 16
        repeat: expr
        repeat-expr: count
  hash_block4:
    seq:
      - id: count
        type: u4
      - id: hashes
        size: 4
        repeat: expr
        repeat-expr: count
  file_lists:
    seq:
      - id: count
        type: u4
      - id: lists
        type: counted_strings
        repeat: expr
        repeat-expr: count
  legacy_table:
    seq:
      - id: blob_size
        type: u4
      - id: string_blob
        size: blob_size
        doc: Run of NUL-terminated file and directory names.
      - id: num_indexes
        type: u4
      - id: string_index
        type: u4
        repeat: expr
        repeat-expr: num_indexes
        doc: Offsets into `string_blob`.
      - id: num_entries
        type: u4
      - id: entries
        type: legacy_entry
        repeat: expr
        repeat-expr: num_entries
  legacy_entry:
    seq:
      - id: offset_u8
        type: u8
        if: _root.version >= 4
      - id: offset_u4
        type: u4
        if: _root.version < 4
      - id: file_name_index
        type: u4
      - id: dir_name_index
        type: u4
      - id: size
        type: u4
      - id: inflated_size
        type: u4
        doc: 0 = stored.
  modern_table:
    seq:
      - id: num_entries
        type: u4
      - id: entries
        type: modern_entry
        repeat: expr
        repeat-expr: num_entries
      - id: num_hashes
        type: u4
      - id: hash_table
        size: 4
        repeat: expr
        repeat-expr: num_hashes
  modern_entry:
    seq:
      - id: offset
        type: u8
      - id: path
        type: lstring
      - id: flag
        type: s4
      - id: size
        type: u4
      - id: unknown
        type: u4
        if: _root.version <= 9
