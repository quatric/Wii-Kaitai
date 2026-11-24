meta:
  id: ifp_anct
  title: Manhunt 2 animation package (.ifp, ANCT)
  file-extension: ifp
  endian: be
doc: '"ANCT" u32 block count, then per block "BLOC" {u32 length, block name} and an ANPK pack (see mh2_anim).'
seq:
  - id: magic
    contents: ANCT
  - id: block_count
    type: u4
  - id: blocks
    type: block
    repeat: expr
    repeat-expr: block_count
types:
  block:
    seq:
      - id: tag
        contents: BLOC
      - id: length
        type: u4
      - id: name
        size: length
        type: strz
        encoding: ASCII
      - id: name_pad
        size: (-length) % 4
