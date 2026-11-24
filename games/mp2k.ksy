meta:
  id: mp2k
  title: GBA MusicPlayer2000 ("Sappy" / m4a) song header
  endian: le
doc: |
  Songs are located through the sound engine's song table in the ROM (.gba);
  each entry is {u32 pointer, u16 group, u16 group}. Song header: u8 track count,
  u8 block count, u8 priority, u8 reverb, u32 voicegroup pointer, then u32 track
  pointers.
seq:
  - id: track_count
    type: u1
  - id: block_count
    type: u1
  - id: priority
    type: u1
  - id: reverb
    type: u1
  - id: voicegroup_ptr
    type: u4
  - id: track_ptrs
    type: u4
    repeat: expr
    repeat-expr: track_count
