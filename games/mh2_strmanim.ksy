meta:
  id: mh2_strmanim
  title: Manhunt 2 streamed animation archive (strmanim_wii.bin)
  file-extension: bin
  endian: be
doc: |
  A small index of u32 words holding {offset, size} pairs (offsets aligned to
  0x800) next to group markers, then animation packs, each starting "ANPK" u32 3,
  "NAME" {u32 length, animation name} like the packs in an .ifp (see mh2_anim).
seq:
  - id: index
    size-eos: true
types:
  pair:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
