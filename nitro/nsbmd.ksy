meta:
  id: nsbmd
  file-extension: nsbmd
  endian: le
  title: Nitro (DS) NSBMD model container
doc: |
  The Nintendo DS's model container -- `BMD0` -- built on the Nitro SDK's
  general "3D info list" dictionary, the same fixed-header/data-array/
  16-byte-name-table shape used for every kind of dictionary inside it
  (models, bones, shapes). A `BMD0` file is a small block table (usually
  one `MDL0` and one `TEX0`); this definition follows the `MDL0` side down
  to the bone names and each shape's raw geometry-engine command stream,
  matching what this project's C reference actually decodes.

  Two things make NSBMD's offset arithmetic easy to get subtly wrong, and
  both were confirmed by direct address probing against real files (not
  just by reading the C comments) before being written down here:

  * **Dictionary entry offsets are relative to different bases depending
    on which dictionary it is**, and the difference is real, not a typo
    in one or the other. The model dictionary is read with its base
    pointer set to `mdl0_start + 8` (right after the block header), but
    the raw offset value its one entry stores is relative to
    `mdl0_start` itself -- 8 bytes further back than the dictionary
    header that contains it. The shape dictionary has no such skew: its
    entries' offsets are relative to the shape dictionary's own header
    address. Both were verified by resolving the pointer both ways and
    checking which one lands on a real `MDL0` model header and a real
    `0x00100000`-tagged shape header, respectively.
  * **A shape's display-list offset is relative to the shape header, not
    self-relative to the field that stores it and not relative to the
    model.** The reference C computes it as `(shape_addr - model_addr) +
    dl_off`, then re-adds `model_addr` to get an absolute address --
    which algebraically cancels to `shape_addr + dl_off`, the simpler
    form this definition uses directly.

  The bone dictionary carries only names here; NSBMD has no direct
  parent/child field in the bone dictionary itself, and the reference C
  recovers that hierarchy as a side effect of interpreting the model's
  render-command list (`0x06` "multiply with bone matrix" opcodes) -- a
  separate, stateful decode this definition does not attempt. Likewise,
  a shape's `display_list` is left as raw bytes: it is the DS geometry
  engine's packed FIFO command stream (four opcode bytes per word,
  parameters trailing each), and turning that into vertices is a
  different kind of work from describing the container, the same line
  `bch.ksy` draws at PICA200 command streams.

  Verified against six real DS titles' models:

  * **`giratina.nsbmd`** (Pokémon Platinum's title-screen model,
    `ok1/res/graphics/title_screen/`, 54,856 bytes): `bom` `0xfeff`, two
    blocks (`MDL0` at `0x18`, `TEX0` at `0x9344`), one model
    (`title_gira`), **27** bones by dictionary count -- `world_root`,
    `joint8`, `joint1`..`joint23`, `polySurface189`, matching this
    project's own prior cross-check of 26/27 joints resolving a parent
    via the render-command decode -- and 4 shapes (`polygon0`..
    `polygon3`), every one of whose headers opens with the expected
    `0x00100000` tag.
  * **`kawashima.nsbmd`** (Brain Age 2's facial rig,
    `Datafiles/dataWW/Model/`, 21,740 bytes): single block, `bom`
    `0xfeff`, `len_file` matching the real file size exactly, 21 bones
    (`skl_root`, `face`, `brow_l1`/`l2`/`l3`, ... matching this project's
    own prior note about that same joint chain) and 13 shapes, every
    header tag `0x00100000`.
  * **`giratina_portal.nsbmd`** and **`giratina_face.nsbmd`** (the same
    title screen's other two models, same directory): 7/8 and 4/3
    bones/shapes respectively, all shape tags `0x00100000`.
  * **`crystal.nsbmd`** and **`ug_base_cur.nsbmd`** (from a Pokémon
    Crystal/HGSS decompilation project's data tree): single
    bone/single shape each, both resolving cleanly and both matching
    the `0x00100000` tag.
seq:
  - id: magic
    contents: "BMD0"
  - id: bom
    type: u2
    doc: 0xfeff on every real sample; `ParseNSBMD()` requires exactly this.
  - id: version
    type: u2
    doc: 0x0002 on both samples checked.
  - id: len_file
    type: u4
    doc: Matches the real file length on both samples.
  - id: header_size
    type: u2
    doc: 0x0010 on both samples -- the size of this header, block table included up to `num_blocks` array start.
  - id: num_blocks
    type: u2
  - id: block_offsets
    type: u4
    repeat: expr
    repeat-expr: num_blocks
instances:
  blocks:
    pos: 0
    type: block(block_offsets[_index])
    repeat: expr
    repeat-expr: num_blocks
    doc: |
      One entry per `block_offsets` slot. The `MDL0` block is usually
      `blocks[0]` (both samples here have it first, with `TEX0` after),
      but nothing in the header guarantees an order -- scan for
      `magic == "MDL0"` rather than assuming the index. `block` has no
      `seq` of its own precisely so that constructing this array does not
      need to seek to each (non-contiguous) block in turn -- every field
      is a lazily-evaluated instance addressed off `base` instead.
types:
  block:
    doc: |
      A block table entry. Deliberately carries no `seq`: `block_offsets`
      entries are not contiguous in the file, so every field here is an
      instance resolved from `base` on demand rather than something read
      sequentially at construction time.
    params:
      - id: base
        type: u4
    instances:
      magic:
        pos: base
        type: str
        size: 4
        encoding: ASCII
      len_block:
        pos: base + 4
        type: u4
      mdl0:
        pos: base + 8
        type: mdl0_body(base)
        if: magic == "MDL0"

  mdl0_body:
    doc: |
      The payload of an `MDL0` block. Has no `seq` of its own: this type
      exists purely as an addressing anchor, since the model dictionary's
      one real entry stores an offset relative to `base` (the block's
      own start, 8 bytes before this dictionary's header) rather than to
      where the dictionary itself lives.
    params:
      - id: base
        type: u4
    instances:
      models_dict_addr:
        value: base + 8
      models_dict:
        pos: models_dict_addr
        type: nitro_dict(models_dict_addr)
      model_off_addr:
        value: models_dict.data_addr
        doc: Address of the (only decoded) first model dictionary entry's raw offset word.
      model_off:
        pos: model_off_addr
        type: u4
        doc: Relative to `base` (the MDL0 block start) -- not to `models_dict_addr`.
      model:
        pos: base + model_off
        type: model(base + model_off)
        if: models_dict.n > 0

  # Nitro's general "3D info list" dictionary: an 8-byte header, an
  # (n+1)-word unknown table, a 4-byte info block (item size + offset to
  # the name table), n data records of that item size, then n 16-byte
  # fixed name slots. Every offset this type resolves to (data_addr,
  # names_addr) is absolute; what a *data record*'s own content means is
  # up to the caller, since it differs between dictionary kinds (model
  # entries hold a raw offset, shape entries hold one too but at a
  # kind-dependent byte position, bone entries are never read for their
  # data by this project's C reference at all).
  nitro_dict:
    params:
      - id: base
        type: u4
    seq:
      - id: reserved_00
        type: u1
      - id: n
        type: u1
      - id: reserved_02
        type: u2
      - id: reserved_04
        type: u4
      - id: unknown_table
        type: u4
        repeat: expr
        repeat-expr: n + 1
      - id: item_size
        type: u2
        doc: Bytes per data record.
      - id: item_off
        type: u2
        doc: Offset from this dictionary's own header (`base`) to the 16-byte name table.
    instances:
      data_addr:
        value: base + 16 + (n * 4)
        doc: |
          Where the `n` data records (each `item_size` bytes) begin --
          right after this type's own seq fields
          (`base + 8` header `+ 4 + n*4` unknown table `+ 4` info block).
          Computed arithmetically rather than read off `_io.pos` after
          parsing, since this instance can be evaluated long after the
          shared stream cursor has moved elsewhere.
      names_addr:
        value: base + 12 + (n * 4) + item_off
      names:
        pos: names_addr
        type: strz
        encoding: ASCII
        size: 16
        repeat: expr
        repeat-expr: n
        if: n > 0

  model:
    params:
      - id: base
        type: u4
    seq:
      - id: reserved_00
        type: u4
      - id: ofs_render_cmds
        type: u4
        doc: Offset (relative to `base`) of the render-command list that (among other things) carries bone parentage.
      - id: reserved_08
        type: u4
      - id: ofs_shapes
        type: u4
        doc: Offset (relative to `base`) of the shape dictionary.
    instances:
      bones_dict_addr:
        value: base + 0x40
        doc: |
          The bone dictionary sits at a fixed offset in the model header
          -- there is no stored pointer to it, unlike the shape
          dictionary.
      bones_dict:
        pos: bones_dict_addr
        type: nitro_dict(bones_dict_addr)
      shapes_dict_addr:
        value: base + ofs_shapes
      shapes_dict:
        pos: shapes_dict_addr
        type: nitro_dict(shapes_dict_addr)
      render_cmds_addr:
        value: base + ofs_render_cmds
      shapes:
        pos: shapes_dict_addr
        type: shape_ref(shapes_dict_addr, shapes_dict.data_addr + _index * shapes_dict.item_size, shapes_dict.item_size)
        repeat: expr
        repeat-expr: shapes_dict.n

  shape_ref:
    doc: |
      Resolves one shape dictionary data record to its shape header.
      `item_size >= 8` means the record's second word holds the offset;
      a bare 4-byte record holds it directly at the record's own start
      (both samples here use the 4-byte form, `item_size == 4`).
    params:
      - id: sbase
        type: u4
        doc: The shape dictionary's own header address -- what the offset is relative to.
      - id: rec_addr
        type: u4
      - id: item_size
        type: u4
    instances:
      ofs_shape:
        pos: "rec_addr + (item_size >= 8 ? 4 : 0)"
        type: u4
      shape_addr:
        value: sbase + ofs_shape
      shape:
        pos: shape_addr
        type: shape(shape_addr)

  shape:
    params:
      - id: base
        type: u4
    seq:
      - id: tag
        type: u4
        doc: 0x00100000 on every shape header checked, a constant per the C reference's own comment.
      - id: reserved_04
        type: u4
      - id: len_display_list
        type: u4
      - id: ofs_display_list
        type: u4
        doc: Relative to `base` (this shape header's own start).
    instances:
      display_list_addr:
        value: base + ofs_display_list
      display_list:
        pos: display_list_addr
        size: len_display_list
        if: len_display_list > 0
        doc: |
          Raw DS geometry-engine FIFO command stream -- decoding it into
          vertices is out of scope here (see the doc block at the top of
          this file).
