meta:
  id: bflyt
  file-extension: bflyt
  endian: le
  title: NintendoWare BFLYT layout
doc: |
  The 3DS and Wii U successor to the Wii's BRLYT. Magic `FLYT`, a 20-byte
  header, then a flat ordered list of tagged sections -- the same shape as
  BRLYT, with wider name fields and two new section kinds.

  As on the Wii, the pane hierarchy is carried by *order* rather than by
  pointers: `pas1` opens a child list and `pae1` closes it, `grs1`/`gre1`
  do the same for groups. What is new is `prt1`, a pane that instantiates
  another layout file by name, and `cnt1`, which names the panes a part
  exposes to whatever embeds it.

  This definition is little-endian because that is what the 3DS samples
  are. Wii U layouts are big-endian with the same structure; the mark at
  offset 4 tells them apart, and swapping `meta/endian` is the only change
  needed. `sarc.ksy` in this directory shows the parameterised pattern if
  a single definition must handle both.

  BFLYT is properly an NW4C (NintendoWare for CTR) format -- the `Lyt`
  library shipped for the 3DS -- but Nintendo's NW4F (NintendoWare for
  Cafe/Wii U) `Lyt` library is close enough to the same on-disk layout,
  same `FLYT` magic, same section tags, just re-endianed, that the two
  have historically been treated as one format by tooling rather than as
  a 3DS format one console generation later reused verbatim. This
  definition follows that convention and does not distinguish them beyond
  the byte-order mark.

  Field widths grew from BRLYT and are worth stating, because nothing in
  the file announces them: a pane name is 24 bytes, a material name 28, a
  group name 34, and a group's pane references 24 each. All four were
  measured against the sample set rather than assumed -- the material name
  in particular is exactly 28, since testing 32 fails on 455 of 2209
  materials while 28 holds for all of them.
seq:
  - id: magic
    contents: "FLYT"
  - id: bom
    type: u2
    doc: 0xfeff read in this file's own order.
  - id: len_header
    type: u2
    doc: 0x14.
  - id: version
    type: u4
    doc: 0x07020100 across all 299 samples.
  - id: len_file
    type: u4
  - id: num_sections
    type: u2
  - id: reserved
    type: u2
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
types:
  section:
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: len_section
        type: u4
        doc: Size including these eight bytes; the stride to the next section.
      - id: body
        size: len_section - 8
        type:
          switch-on: magic
          cases:
            '"lyt1"': layout
            '"txl1"': string_list
            '"fnl1"': string_list
            '"mat1"': material_list
            '"pan1"': pane
            '"bnd1"': pane
            '"pic1"': picture
            '"txt1"': text_box
            '"wnd1"': window
            '"grp1"': group
        doc: |
          `pas1`, `pae1`, `grs1` and `gre1` are pure markers with no body
          and are always exactly 8 bytes. `prt1`, `cnt1` and `usd1` are
          left as raw bytes: parts and control sections carry
          variable-length property tables whose layout is not settled
          here, and inventing a structure for them would be worse than
          handing back the bytes.

  layout:
    doc: |
      `lyt1`. Unlike BRLYT's, this one carries the layout's own name and
      the maximum size of any part that embeds it.
    seq:
      - id: draw_from_center
        type: u1
      - id: reserved
        size: 3
      - id: width
        type: f4
      - id: height
        type: f4
        doc: 400 x 240 in the 3DS samples -- one screen.
      - id: max_part_width
        type: f4
      - id: max_part_height
        type: f4
      - id: name
        type: strz
        encoding: ASCII

  string_list:
    doc: |
      Shared shape of `txl1` (textures) and `fnl1` (fonts). Offsets are
      relative to the start of the offset table, which is 12 bytes into
      the section, hence 4 into this body. Entries are a bare u4 here --
      BRLYT's second, always-zero word is gone.
    seq:
      - id: num_entries
        type: u4
      - id: entries
        type: string_ref
        repeat: expr
        repeat-expr: num_entries

  string_ref:
    seq:
      - id: ofs_name
        type: u4
    instances:
      name:
        io: _parent._io
        pos: ofs_name + 4
        type: strz
        encoding: ASCII

  material_list:
    doc: |
      `mat1`. Offsets are relative to the start of the *section* -- tag
      included -- unlike the string lists above, so 8 is subtracted to
      index into this body. Past the name a material holds colour
      registers, texture and matrix references, and TEV stages, all sized
      by per-material flags; only the name is broken out.
    seq:
      - id: num_materials
        type: u4
      - id: materials
        type: material_ref
        repeat: expr
        repeat-expr: num_materials

  material_ref:
    seq:
      - id: ofs_material
        type: u4
    instances:
      name:
        io: _parent._io
        pos: ofs_material - 8
        type: str
        size: 28
        encoding: ASCII
        pad-right: 0

  pane:
    doc: |
      `pan1`, and identically `bnd1` -- a bounding pane, which takes part
      in the hierarchy and in hit-testing but draws nothing. Both are
      always 84 bytes.
    seq:
      - id: flags
        type: u1
        doc: Bit 0 is visible; bit 1 makes the pane's alpha influence its children.
      - id: origin
        type: u1
        doc: |
          Packed anchor: `origin % 3` selects left/centre/right,
          `origin / 3` selects top/centre/bottom.
      - id: alpha
        type: u1
      - id: part_scale
        type: u1
      - id: name
        type: str
        size: 24
        encoding: ASCII
        pad-right: 0
      - id: user_data
        type: str
        size: 8
        encoding: ASCII
        pad-right: 0
      - id: translate
        type: vec3
      - id: rotate
        type: vec3
      - id: scale_x
        type: f4
      - id: scale_y
        type: f4
      - id: width
        type: f4
      - id: height
        type: f4

  picture:
    doc: '`pic1`: a textured quad, a pane followed by its corner colours and UVs.'
    seq:
      - id: base
        type: pane
      - id: vertex_colors
        size: 16
        doc: Four RGBA8 corner colours -- top-left, top-right, bottom-left, bottom-right.
      - id: material_index
        type: u2
      - id: num_tex_coords
        type: u1
      - id: reserved
        type: u1
      - id: tex_coords
        type: tex_coord_set
        repeat: expr
        repeat-expr: num_tex_coords
        doc: |
          One set of four UV pairs per texture the material samples. The
          count really does vary here, unlike BRLYT's fixed single set:
          most pictures carry one (136-byte section), some two (168) and a
          few three (200).

  tex_coord_set:
    seq:
      - id: top_left
        type: vec2
      - id: top_right
        type: vec2
      - id: bottom_left
        type: vec2
      - id: bottom_right
        type: vec2

  text_box:
    doc: |
      `txt1`. As on the Wii the reserved length is stored before the used
      one, and both count bytes of UTF-16 rather than characters: a
      60-character message reports 130 then 120. `ofs_text` is relative to
      the start of the section.
    seq:
      - id: base
        type: pane
      - id: len_text_max
        type: u2
      - id: len_text
        type: u2
        doc: Bytes actually stored, the terminating NUL included.
      - id: material_index
        type: u2
      - id: font_index
        type: u2
      - id: alignment
        type: u1
      - id: line_alignment
        type: u1
      - id: flags
        type: u1
      - id: reserved
        type: u1
      - id: italic_tilt
        type: f4
      - id: ofs_text
        type: u4
      - id: color_top
        size: 4
      - id: color_bottom
        size: 4
      - id: font_size_x
        type: f4
      - id: font_size_y
        type: f4
      - id: char_space
        type: f4
      - id: line_space
        type: f4
      - id: rest
        size-eos: true
        doc: |
          Shadow parameters and a tag-name offset follow. They are left
          raw rather than guessed at; the text itself is reachable through
          `text` regardless.
    instances:
      text:
        pos: ofs_text - 8
        size: len_text
        type: str
        encoding: UTF-16LE
        if: ofs_text >= 8

  window:
    doc: |
      `wnd1`: a nine-patch frame. The pane header is typed; the inflation
      rectangle, frame count and per-frame material references that follow
      are sized by the frame count and are left raw.
    seq:
      - id: base
        type: pane
      - id: rest
        size-eos: true

  group:
    doc: |
      `grp1`. Names its members rather than owning them; the runtime
      resolves the names against the pane tree. The 34-byte name is not a
      typo -- `num_panes` sits at offset 42 of the section, which a
      32-byte name would misread, and the 24-byte references then divide
      the remainder exactly.
    seq:
      - id: name
        type: str
        size: 34
        encoding: ASCII
        pad-right: 0
      - id: num_panes
        type: u2
      - id: panes
        type: str
        size: 24
        encoding: ASCII
        pad-right: 0
        repeat: expr
        repeat-expr: num_panes

  vec2:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4

  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
