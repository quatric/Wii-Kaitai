meta:
  id: bch
  file-extension: bch
  endian: le
  title: CTR BCH model container
doc: |
  The 3DS's model, texture and animation container -- `BCH\0`, produced by
  Nintendo's CTR graphics pipeline and consumed by it more or less
  verbatim: much of the file is pre-baked PICA200 command lists rather
  than described geometry.

  BCH is the true NW4C (NintendoWare for CTR) native model format --
  "CTR" is the 3DS's development codename, the direct successor to the
  Wii's "RVL"/Revolution codename that names NW4R. Where BRRES (`nw4r/`)
  is one archive holding whichever model/texture/animation sub-files it
  contains, and BFRES (`nw4c/bfres.ksy`, actually NW4F/"Cafe" -- the Wii
  U's codename, not NW4C at all despite living in this directory) is the
  Wii U's self-relative-pointer redesign of the same idea, BCH is
  CTR-specific: a fixed fifteen-slot content table baked to match the
  PICA200 GPU's own command format, with no Wii U or Switch equivalent.

  The file is six regions laid end to end -- main header, string table,
  GPU commands, data, extended data, relocation table -- each with its own
  offset and length in the header. They chain: every region's offset plus
  its length reaches the next one (with padding), and the relocation
  table's offset plus its length is exactly the file size. That identity
  holds on all three samples and is the cheapest check that a BCH has been
  read correctly.

  The main header is a flat array of fifteen content groups -- models,
  materials, shaders, textures, and so on -- each a triple of *(pointer
  table offset, count, dictionary offset)*, both offsets relative to the
  main header rather than to the file. Fifteen is what these files carry,
  and it is self-evident in them: the first dictionary sits at 0xb4, which
  is exactly fifteen twelve-byte triples past the start.

  Names live in one string table shared by every dictionary, and a
  dictionary entry's `ofs_name` is relative to that table.

  What this definition does **not** describe is the content itself. A
  model, a material or an animation body is a PICA200 register program,
  and turning that into geometry is a different kind of work from parsing
  a container. The dictionaries give you every object's name and the
  pointer tables give you where each body starts; from there you are in
  GPU command territory.
seq:
  - id: magic
    contents: [0x42, 0x43, 0x48, 0x00]
  - id: backward_compatibility
    type: u1
    doc: |
      0x22 in the samples. Above 0x20 the header carries the extended-data
      offset and length, which is why those two fields are conditional --
      an older file simply does not have them and every field after would
      shift by four bytes.
  - id: forward_compatibility
    type: u1
  - id: version
    type: u2
  - id: ofs_main
    type: u4
  - id: ofs_string_table
    type: u4
  - id: ofs_gpu_commands
    type: u4
  - id: ofs_data
    type: u4
  - id: ofs_data_extended
    type: u4
    if: backward_compatibility > 0x20
  - id: ofs_relocation_table
    type: u4
  - id: len_main
    type: u4
  - id: len_string_table
    type: u4
  - id: len_gpu_commands
    type: u4
  - id: len_data
    type: u4
  - id: len_data_extended
    type: u4
    if: backward_compatibility > 0x20
  - id: len_relocation_table
    type: u4
  - id: len_uninitialized_data
    type: u4
  - id: len_uninitialized_description
    type: u4
  - id: flags
    type: u2
  - id: num_addresses
    type: u2
instances:
  content:
    pos: ofs_main
    type: content_group
    repeat: expr
    repeat-expr: 15
    doc: |
      In order: models, materials, shaders, textures, material lookup
      tables, lights, cameras, fogs, skeletal animations, material
      animations, visibility animations, light animations, camera
      animations, fog animations, scenes. The samples exercise models,
      materials, textures, lookup tables and skeletal animations; the rest
      are present with a count of zero, and their names come from
      published tooling rather than from anything measured here.
  models:
    value: content[0]
  materials:
    value: content[1]
  shaders:
    value: content[2]
  textures:
    value: content[3]
  lookup_tables:
    value: content[4]
  skeletal_animations:
    value: content[8]
  string_table:
    pos: ofs_string_table
    size: len_string_table
    doc: NUL-terminated names, indexed by every dictionary in the file.
  gpu_commands:
    pos: ofs_gpu_commands
    size: len_gpu_commands
    if: len_gpu_commands > 0
    doc: Pre-baked PICA200 register writes; not described here.
  data:
    pos: ofs_data
    size: len_data
    if: len_data > 0
  relocation_table:
    pos: ofs_relocation_table
    size: len_relocation_table
    doc: |
      Patch list applied at load time to turn the file's relative offsets
      into addresses in place.
types:
  content_group:
    doc: |
      One kind of object. `num_entries` is authoritative -- a group with
      none still has a dictionary offset pointing at a bare root node.
    seq:
      - id: ofs_pointer_table
        type: u4
      - id: num_entries
        type: u4
      - id: ofs_dict
        type: u4
    instances:
      dict:
        pos: _root.ofs_main + ofs_dict
        type: dictionary(num_entries)
        if: num_entries > 0
      pointers:
        pos: _root.ofs_main + ofs_pointer_table
        type: u4
        repeat: expr
        repeat-expr: num_entries
        if: num_entries > 0 and ofs_pointer_table != 0
        doc: |
          One offset per entry, in the same order as the dictionary, to
          that object's body. Also relative to the main header.

  dictionary:
    doc: |
      A radix tree, the same idea as BRRES's resource group: a sentinel
      root whose `reference_bit` is 0xffffffff, then one node per entry.
      Nothing needs the tree to enumerate a group -- the nodes can be read
      in order -- so `reference_bit` and the two child indices only matter
      to code looking a name up.
    params:
      - id: num_entries
        type: u4
    seq:
      - id: root
        type: node
      - id: entries
        type: node
        repeat: expr
        repeat-expr: num_entries

  node:
    seq:
      - id: reference_bit
        type: u4
      - id: idx_left
        type: u2
      - id: idx_right
        type: u2
      - id: ofs_name
        type: u4
        doc: Relative to the file's string table; 0 on the root sentinel.
    instances:
      name:
        io: _root._io
        pos: _root.ofs_string_table + ofs_name
        type: strz
        encoding: ASCII
        if: reference_bit != 0xffffffff
