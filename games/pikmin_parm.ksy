meta:
  id: pikmin_parm
  title: Pikmin 1 tagged parameter list (.bin)
  file-extension: bin
  endian: be
doc: |
  Pikmin 1 tagged parameter lists (`parms/*.bin`, camera and similar;
  `Parameters::read` in the decompilation): repeated `{3 character id, u8 size}
  + size bytes`, ended by 0xFFFFFFFF. A file is one such list, or several back to
  back (naviMgr, pikiMgr, pelMgr), optionally after a 4 or 16 byte prefix. The
  files carry no types; values are interpreted by size.
seq:
  - id: entries
    type: entry
    repeat: until
    repeat-until: _.is_end
types:
  entry:
    seq:
      - id: id
        size: 3
      - id: len_value
        type: u1
      - id: value
        size: len_value
        if: not is_end
    instances:
      is_end:
        value: id[0] == 0xff and id[1] == 0xff and id[2] == 0xff and len_value == 0xff
