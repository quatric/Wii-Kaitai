meta:
  id: atlus_ndx
  title: Atlus DS/3DS archive name directory (.ndx)
  file-extension: ndx
  endian: le
doc: |
  Name directory of Atlus's DS/3DS archive system (Radiant Historia, Shin
  Megami Tensei: Strange Journey / Devil Survivor, Etrian Odyssey). One
  archive is three files:

  * `.ndx` -- this file, a tree of names. Directory blocks are located by
    absolute offsets inside the `.ndx`.
  * `.idx` -- a hash table from the full path to `(offset, size)`; see
    `atlus_idx.ksy`.
  * `.bin` -- the concatenated payloads.

  A directory block is `u16 count` followed by `count` entries. An entry with
  `child_offset == 0` is a file; otherwise it is a directory whose block
  starts at `child_offset`. The root block is at offset 0. The full path of a
  file is its names joined with `/`; that string is what the `.idx` hash is
  computed from.

  nintoolbox's detector requires 1..256 root entries, names of 1..128
  printable ASCII bytes, and the first child block to start past the root
  entry list.
seq:
  - id: root
    type: directory
types:
  directory:
    seq:
      - id: entry_count
        type: u2
      - id: entries
        type: entry
        repeat: expr
        repeat-expr: entry_count
  entry:
    seq:
      - id: name_len
        type: u2
      - id: name
        type: str
        size: name_len
        encoding: ASCII
        doc: Not NUL-terminated.
      - id: child_offset
        type: u4
        doc: Absolute offset of the child directory block, or 0 for a file.
    instances:
      is_dir:
        value: child_offset != 0
      child:
        pos: child_offset
        type: directory
        io: _root._io
        if: child_offset != 0
