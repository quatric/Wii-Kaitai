meta:
  id: tera
  title: Nintendo tera terrain TARB tile (Mario Kart World)
  endian: le
doc: |
  Tile layers .hght / .mate / .norm / *.extm. 0x14-byte header ("TARB",
  version, header size, payload size, zstd size or 0) then a payload starting
  with a 0x34-byte info block: 0x00 u16 BE grid side, 0x02 u8 margin, 0x03 u8
  array slices, 0x04 u8[4] per-channel type of the data block (6 = 8 bit,
  9 = 16 bit, 0x0b = 32-bit float, 08 08 07 = R11G11B10F), 0x08 u8 flags (0x80
  delta packed), 0x14 u8[4] GPU block format (0x30 BC1, 0x34 BC3, 0xc6 BC5,
  0xc8 BC6H), 0x19 u8 mip count, 0x1C/0x24/0x2C {s32 offset relative to the
  field, u32 size}: data, aux, GPU blocks.
seq:
  - id: magic
    contents: TARB
  - id: version
    type: u4
  - id: header_size
    type: u4
  - id: payload_size
    type: u4
  - id: zstd_size
    type: u4
    doc: 0 when uncompressed.
  - id: payload
    size-eos: true
types:
  info:
    seq:
      - id: grid_side
        type: u2be
      - id: margin
        type: u1
      - id: array_slices
        type: u1
      - id: channel_types
        size: 4
      - id: flags
        type: u1
      - id: unk09
        size: 0x14 - 9
      - id: gpu_format
        size: 4
      - id: unk18
        type: u1
      - id: mip_count
        type: u1
      - id: unk1a
        size: 2
      - id: data_block
        type: block_ref
      - id: aux_block
        type: block_ref
      - id: gpu_block
        type: block_ref
  block_ref:
    seq:
      - id: offset_rel
        type: s4
      - id: size
        type: u4
