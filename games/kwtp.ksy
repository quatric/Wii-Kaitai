meta:
  id: kwtp
  title: Konami kwtp02 texture pack (.kwtp)
  file-extension: kwtp
  endian: be
doc: |
  Konami / Mahjong Fight Club `kwtp02` texture pack (Wii). A head, a table of
  0x18-byte sprite records and an ordinary TPL (`00 20 af 30`) at `tpl_offset`
  (0x140 in the fonts). The head's remaining fields and the sprite records are
  not decoded by nintoolbox and are left raw.
seq:
  - id: magic
    contents: kwtp02
  - id: head_prefix
    size: 0x12
  - id: tpl_offset
    type: u4
  - id: num_sprites
    type: u4
instances:
  tpl:
    pos: tpl_offset
    size-eos: true
