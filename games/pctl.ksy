meta:
  id: pctl
  title: NintendoWare particle-effect archive (VFXB / .ptcl)
  file-extension:
    - ptcl
    - eset
  endian: le
  license: CC0-1.0

doc: |
  NintendoWare particle-effect archive, magic "VFXB". Used by Wii U / Switch
  titles built with the NintendoWare effect library (EffectLibrary). Holds a
  flat, singly-linked chain of typed sections (emitters, emitter sets,
  textures, embedded model/shader/texture archives, primitive geometry).

  Reference: nintoolbox project/src/lib-pctl.c (DecodePCTL_Text /
  ExtractPCTLArchive), cross-checked against KillzXGaming/Switch-Toolbox
  File_Format_Library/FileFormats/Effects/PCTL.cs and EffectLibrary.

seq:
  - id: magic
    contents: "VFXB"
  - id: reserved1
    size: 4
  - id: graphics_api_version
    type: u2
  - id: vfx_version
    type: u2
  - id: byte_order_mark
    type: u2
  - id: alignment
    type: u1
  - id: target_offset
    type: u1
  - id: header_size
    type: u4
  - id: flag
    type: u2
  - id: block_offset
    type: u2
  - id: reserved2
    size: 4
  - id: file_size
    type: u4
  - id: name
    size: 32
    type: str
    encoding: ASCII
    if: _io.size >= 64

instances:
  first_section:
    pos: block_offset
    type: section
    if: block_offset > 0

types:
  section:
    doc: |
      One 32-byte section header. `subsection_offset`, `next_section_offset`
      and `binary_data_offset` are offsets relative to the start of this
      section header; a value of 0xFFFFFFFF means "not present". Section
      bodies are opaque here -- see lib-pctl.c's decode_section() for the
      per-signature payload layouts (TEXR, TEXA, GX2B, EMTR, ESET, ESTA,
      ESFT, GTNT, G3NT, GRTF, G3PR, GRSN, PRMA).
    seq:
      - id: signature
        size: 4
        type: str
        encoding: ASCII
      - id: section_size
        type: u4
      - id: subsection_offset
        type: u4
      - id: next_section_offset
        type: u4
      - id: reserved
        size: 4
      - id: binary_data_offset
        type: u4
      - id: reserved2
        size: 4
      - id: subsection_count
        type: u4
    instances:
      has_binary:
        value: binary_data_offset != 0xffffffff
      has_next:
        value: next_section_offset != 0xffffffff
      has_subsection:
        value: subsection_offset != 0xffffffff
