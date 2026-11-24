meta:
  id: toshi_tso
  title: Blue Tongue Toshi scripted sequence (.tso, Barnyard Wii)
  file-extension: tso
  endian: be
doc: |
  After OpenBarnyard ASSeq. Offsets other than the header are relative to the
  end of the 24-byte header. Script at base: {char *name, s32 ?, s32 track
  count, s32 *track actor ids, u32 *track offsets}. Instruction sizes by type:
  0 actor event 0x1c, 1 actor event 0x14, 2 actor event 0x1c, 3 wait 0x14,
  4 animation 0x1c, 5 voice 0x18, 6 unused 0x18, 7 fade 0x14, 8 actor flag
  0x10, 9 set flag 0x10, 10 pause 0xc, 11 resume 0xc, 12 command 0x1c, 13 end.
seq:
  - id: string_reloc_offset
    type: u4
  - id: string_reloc_size
    type: u4
  - id: strings_offset
    type: u4
  - id: pointer_reloc_offset
    type: u4
  - id: pointer_reloc_size
    type: u4
  - id: pointers_offset
    type: u4
  - id: script
    type: script
types:
  script:
    seq:
      - id: name_ptr
        type: u4
      - id: unk
        type: s4
      - id: track_count
        type: s4
      - id: actor_ids_ptr
        type: u4
      - id: track_offsets_ptr
        type: u4
  instruction_head:
    seq:
      - id: type
        type: s4
      - id: flags
        type: u4
      - id: flag
        type: s4
