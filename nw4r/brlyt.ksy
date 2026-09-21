meta:
  id: brlyt
  file-extension: brlyt
  endian: be
  title: NW4R BRLYT layout
doc: |
  A 2D layout: the screen-space UI description used by Wii system menus,
  channels and in-game HUDs. Its own magic is `RLYT`.

  After a 16-byte header the file is a flat, ordered list of tagged
  sections. The pane *hierarchy* is not expressed by pointers but by the
  order of those sections: `pas1` opens a child list and `pae1` closes it,
  so a pane that appears between them is a child of the pane before the
  `pas1`. `grs1`/`gre1` do the same for groups.

  Two different offset bases are in use, which is the classic way to
  misparse this format:

  * `txl1` and `fnl1` name offsets are relative to the **start of their
    entry table**, i.e. 12 bytes into the section;
  * `mat1` material offsets and `txt1`'s text offset are relative to the
    **start of the section**, tag included.

  Both were confirmed by locating the strings independently in 250 retail
  layouts.

  BRLYT is NW4R's 2D layout format, reused with only cosmetic renaming as
  BFLYT on Wii U and CLYT on 3DS; community documentation for all three
  (tockdom's Mario Kart Wii wiki, KillzXGaming's Switch-Toolbox notes)
  describes the same section tags and pane header shape, which is how
  several fields below were cross-checked. Note that the outside
  community usually calls a pane's `flags` byte 0 bits "widescreen" /
  "influence alpha" / "visible" (in that bit order) rather than the two
  bits this definition names -- worth re-checking against a widescreen
  layout sample if that distinction ever matters here.
doc-ref: 'https://mkwiiki.org/wiki/BRLYT_(File_Format) (tockdom Mario Kart Wii wiki, BRLYT/BFLYT/CLYT share the same NW4R layout section layout)'
seq:
  - id: magic
    contents: "RLYT"
  - id: bom
    type: u2
  - id: version
    type: u2
    doc: 0x8 and 0xa both occur in retail Wii layouts (45 and 205 of 250 samples).
  - id: len_file
    type: u4
  - id: len_header
    type: u2
    doc: 0x10; the first section starts here.
  - id: num_sections
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
        doc: Size of this section including these eight bytes; the stride to the next one.
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
          `pas1`/`pae1` and `grs1`/`gre1` have no body at all -- they are
          pure open/close markers and are always exactly 8 bytes.

  layout:
    doc: The `lyt1` section; always 20 bytes, so 12 of body.
    seq:
      - id: draw_from_center
        type: u1
      - id: reserved
        size: 3
      - id: width
        type: f4
      - id: height
        type: f4

  string_list:
    doc: |
      Shared shape of `txl1` (texture list) and `fnl1` (font list). The
      entry offsets are measured from the start of the entry table, which
      begins 12 bytes into the section -- so 4 bytes into this body.
    seq:
      - id: num_entries
        type: u2
      - id: reserved
        type: u2
      - id: entries
        type: string_ref
        repeat: expr
        repeat-expr: num_entries

  string_ref:
    seq:
      - id: ofs_name
        type: u4
      - id: reserved
        type: u4
    instances:
      name:
        io: _parent._io
        pos: ofs_name + 4
        type: strz
        encoding: ASCII
        doc: |
          `+ 4` converts from "relative to the entry table" to "relative
          to this body", the entry table starting after `num_entries` and
          its padding.

  material_list:
    doc: |
      `mat1`. Each offset is relative to the start of the *section*, so 8
      bytes are subtracted to index into this body. A material carries a
      20-byte name followed by colour registers, texture references, TEV
      stages and blend state, all of which vary in size with per-material
      flags -- only the name is broken out here. Community tooling
      (tockdom's BRLYT page, and BrawlBox/Switch-Toolbox's BFLYT reader
      for the near-identical Wii U format) lays out a bitfield right
      after the name that says which of those optional blocks are
      present and how many texture maps/SRTs/TEV stages to expect; that
      bitfield is not modelled here, so a full material body still has to
      be walked by that external spec rather than by this file.
    seq:
      - id: num_ofs_materials
        type: u2
      - id: reserved
        type: u2
      - id: ofs_materials
        type: u4
        repeat: expr
        repeat-expr: num_ofs_materials

  pane:
    doc: |
      `pan1`, and identically `bnd1` (a bounding pane, which participates
      in the hierarchy and hit-testing but draws nothing). Both are always
      76 bytes across the whole sample set.
    seq:
      - id: flags
        type: u1
        doc: Bit 0 is visible; bit 1 makes the pane's alpha influence its children.
      - id: origin
        type: u1
        doc: |
          Packed anchor: `origin % 3` selects left/centre/right and
          `origin / 3` selects top/centre/bottom.
      - id: alpha
        type: u1
      - id: reserved
        type: u1
      - id: name
        type: str
        size: 16
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
    doc: |
      `pic1`: a textured quad. Always 128 bytes -- the texture-coordinate
      block is fixed at one set even though `num_tex_coords` could in
      principle say otherwise, which is why the section size never varies
      in the sample set.
    seq:
      - id: base
        type: pane
      - id: vertex_colors
        size: 16
        doc: Four RGBA8 corner colours, in top-left, top-right, bottom-left, bottom-right order.
      - id: material_index
        type: u2
      - id: num_tex_coords
        type: u1
      - id: reserved
        type: u1
      - id: tex_coords
        type: f4
        repeat: expr
        repeat-expr: 8
        doc: Four UV pairs, matching the four corners.

  text_box:
    doc: |
      `txt1`. The string itself is UTF-16BE and lives at `ofs_text`,
      measured from the start of the section, with `len_text` counting
      *bytes* rather than characters -- a two-character string reports 4.
    seq:
      - id: base
        type: pane
      - id: len_text_max
        type: u2
        doc: |
          Bytes reserved for the string, which is the size the layout was
          authored with rather than the size in this file -- a 68-byte
          Japanese message can sit in a 362-byte buffer.
      - id: len_text
        type: u2
        doc: |
          Bytes actually stored, the terminating NUL included. The section
          is then padded up to a multiple of 4, so `ofs_text + len_text`
          can fall up to two bytes short of `len_section`.
      - id: material_index
        type: u2
      - id: font_index
        type: u2
      - id: alignment
        type: u1
      - id: justification
        type: u1
      - id: reserved
        type: u2
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
    instances:
      text:
        pos: ofs_text - 8
        size: len_text
        type: str
        encoding: UTF-16BE
        if: ofs_text >= 8

  window:
    doc: |
      `wnd1`: a nine-patch frame. The pane header is typed; the frame
      material and per-corner texture data that follow vary in size with
      the frame count and are left raw here. Per tockdom's BRLYT notes, a
      window can be built from 1, 4 or 8 frame pieces (a single stretched
      texture, or a border split into edges, or edges plus corners), and
      that frame count -- not modelled here -- drives how many
      per-frame texture-coordinate/material records follow the header.
    seq:
      - id: base
        type: pane
      - id: rest
        size-eos: true

  group:
    doc: |
      `grp1`. Holds no panes itself -- it names them, and the layout
      engine resolves the names against the pane tree.
    seq:
      - id: name
        type: str
        size: 16
        encoding: ASCII
        pad-right: 0
      - id: num_panes
        type: u2
      - id: reserved
        type: u2
      - id: panes
        type: str
        size: 16
        encoding: ASCII
        pad-right: 0
        repeat: expr
        repeat-expr: num_panes

  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
