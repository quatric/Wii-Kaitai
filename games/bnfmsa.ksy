meta:
  id: bnfmsa
  file-extension: bnfmsa
  endian: be
  title: Nintendo/Nd Cube BNFMSA skeletal animation
doc: |
  Sidecar skeletal-animation blob for a BNFM model (see `bnfm.ksy`), 10
  SRT (scale/rotate/translate) tracks per bone, Normal/Hermite keys.
  This .ksy covers the fixed 76-byte header; the animation-info and
  bone-track tables it points to have per-entry layouts not modeled
  here (see lib-bnfm.c's `AppendBNFMSAAnimation`).
seq:
  - id: num_bones
    type: u4
  - id: num_anims
    type: u4
  - id: num_bone_anims
    type: u4
  - id: unknown0
    size: 32
    doc: |
      Bytes 0x0c-0x2b: numTracks, unk, numConstantTracks, numKeyFrames,
      numKeyedTracks, plus further unknowns; not decoded by this tool's
      reader.
  - id: ofs_bone_info
    type: u4
  - id: ofs_anim_info
    type: u4
  - id: ofs_bone_anim
    type: u4
  - id: unknown1
    size: 24
    doc: |
      Bytes 0x38-0x4f: boneTrackOffset, unk, constantKeys, keyedFrames,
      stringTable; reserved for fuller tooling, not modeled here.
instances:
  anim_info:
    io: _root._io
    pos: ofs_anim_info
    size: 32
    if: ofs_anim_info < _io.size
    doc: |
      First animation-info record; frame count sits at byte offset 24
      within it. Further records/fields are not modeled here.
