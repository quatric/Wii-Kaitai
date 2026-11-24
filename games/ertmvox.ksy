meta:
  id: ertmvox
  title: Telltale ERTM .vox voice line (Speex frames)
  file-extension: vox
  endian: le
doc: |
  "ERTM" {u32 version 1, ...}; at 0x1c a byte 0 then u32 frame size (640),
  sample rate (32000), Speex mode (0 narrow, 1 wide, 2 ultra-wide), table byte
  size + 8, frame count N, N u32 frame start offsets (relative to the end of the
  table); every frame is one raw Speex frame (the last runs to EOF).
seq:
  - id: magic
    contents: ERTM
  - id: version
    type: u4
  - id: unk8
    size: 0x1c - 8
  - id: zero
    type: u1
  - id: frame_size
    type: u4
  - id: sample_rate
    type: u4
  - id: speex_mode
    type: u4
  - id: table_size_plus_8
    type: u4
  - id: frame_count
    type: u4
  - id: frame_offsets
    type: u4
    repeat: expr
    repeat-expr: frame_count
  - id: frames
    size-eos: true
