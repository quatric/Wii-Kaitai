meta:
  id: nxof
  title: Nihon Falcom nxof Opus (.nxopus, Ys X)
  file-extension: nxopus
  endian: le
doc: Packets are u32 BE size + u32 final range + packet from the data start (pre-skip 312).
seq:
  - id: magic
    size: 4
  - id: unk4
    size: 1
  - id: channels
    type: u1
  - id: unk6
    size: 2
  - id: rate
    type: u4
  - id: unk0c
    size: 0x18 - 0x0c
  - id: data_start
    type: u4
  - id: data_size
    type: u4
  - id: samples
    type: u4
