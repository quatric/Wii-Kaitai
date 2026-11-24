meta:
  id: tecmoad
  title: Tecmo resource pack (Rygar Wii)
  endian: be
doc: |
  `.mad`, `.lad`, `.efe`, `.clf`. Member offsets (0 = unused) need not be
  sorted; a member ends at the next larger offset or EOF. Members start with
  their own tag.
seq:
  - id: pack_tag
    size: 8
  - id: count
    type: u4
  - id: unk0c
    size: 4
  - id: file_size
    type: u4
  - id: x20_a
    type: u4
  - id: x20_b
    type: u4
  - id: unk1c
    size: 4
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: count
