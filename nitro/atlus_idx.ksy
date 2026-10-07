meta:
  id: atlus_idx
  title: Atlus DS/3DS archive hash index (.idx)
  file-extension: idx
  endian: le
doc: |
  Hash lookup index of Atlus's DS/3DS archive system (see `atlus_ndx.ksy` for
  the name tree and the overall three-file layout). It maps a full path to an
  `(offset, size)` pair inside the `.bin` payload file.

  Lookup: the bucket number is `hash(path) & (bucket_count - 1)` where

      c0 = lower(path[0]) with '\' -> '/'
      h  = (c0 == '/') ? 0 : c0
      for each following byte c (lowered, '\' -> '/'):  h = h * 37 + c   (mod 2^32)

  The bucket's `w0`/`w4` words give a "default size"
  `((w4 << 16) >> 10) + (w0 >> 26)`. If `w0 & 1 == 0` the bucket is a direct
  entry: `offset = (((w0 << 6) mod 2^32) >> 7) << 2`, `size = default size`.
  Otherwise it is a collision list located at index-file offset
  `((w0 << 6) mod 2^32) >> 7`.

  A collision list is `u8 item_count` and then items. Item 0 is
  `{u32 offset_div4}` followed by match pairs and uses the default size; items
  1+ are `{u32 offset_div4, u32 size}` followed by match pairs. Match pairs are
  `(u8 char, u8 path_index)` repeated until a `char` of 0; an item matches when
  every `char` equals (case-insensitively) the path byte at `path_index`.
  The `.bin` offset is `offset_div4 << 2`.
seq:
  - id: bucket_count
    type: u2
    doc: Normally 2048 (0x800); a power of two.
  - id: padding
    size: 6
  - id: buckets
    type: bucket
    repeat: expr
    repeat-expr: bucket_count
types:
  bucket:
    seq:
      - id: w0
        type: u4
      - id: w4
        type: u2
    instances:
      default_size:
        value: '(((w4 << 16) & 0xffffffff) >> 10) + (w0 >> 26)'
      is_collision_list:
        value: (w0 & 1) != 0
      direct_offset:
        value: '((((w0 << 6) & 0xffffffff) >> 7) << 2)'
        if: not is_collision_list
      list_offset:
        value: '(((w0 << 6) & 0xffffffff) >> 7)'
        if: is_collision_list
      list:
        pos: list_offset
        type: collision_list
        io: _root._io
        if: is_collision_list
  collision_list:
    seq:
      - id: item_count
        type: u1
      - id: first_item
        type: item(true)
        if: item_count > 0
      - id: other_items
        type: item(false)
        repeat: expr
        repeat-expr: 'item_count > 0 ? item_count - 1 : 0'
  item:
    params:
      - id: is_first
        type: bool
    seq:
      - id: offset_div4
        type: u4
      - id: size
        type: u4
        if: not is_first
        doc: Absent on item 0, which uses the bucket's default size.
      - id: matches
        type: match_pair
        repeat: until
        repeat-until: _.ch == 0
    instances:
      bin_offset:
        value: offset_div4 << 2
  match_pair:
    seq:
      - id: ch
        type: u1
      - id: path_index
        type: u1
        if: ch != 0
