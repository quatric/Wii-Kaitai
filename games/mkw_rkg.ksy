meta:
  id: mkw_rkg
  endian: be
  title: Mario Kart Wii RKG ghost data
doc: |
  Mario Kart Wii RKG ghost-replay file, ported from `rkg_head_t` in
  lib-rkg.h. Reference: https://wiki.tockdom.com/wiki/RKG
seq:
  - id: magic
    contents: "RKGD"
  - id: score_min
    type: b7
  - id: score_sec
    type: b7
  - id: score_milli
    type: b10
  - id: track_id
    type: u1
  - id: id
    type: u4
  - id: kind
    type: u2
  - id: data_size
    type: u2
    doc: Decompressed input-data size.
  - id: any_data
    size: 0x88 - 0x10
