meta:
  id: lxbd
  title: Spectrobes Origins DATA.LXBD
  file-extension: lxbd
  endian: be
doc: |
  Spectrobes: Origins `DATA.LXBD` (1 GB, LXTools): a run of `RPCL` entries at
  0x800-aligned offsets (see `genki_lxhd` for the index); an entry runs to the
  next `RPCL`. There is no name table in the file.
seq:
  - id: first_entry
    type: rpcl_entry
types:
  rpcl_entry:
    seq:
      - id: magic
        contents: RPCL
      - id: one
        type: u4
      - id: codec
        contents: LLZ7
      - id: len_decompressed
        type: u4
      - id: reserved
        size: 0x10
      - id: lz11_stream
        size-eos: true
        doc: Nintendo LZ11 stream at +0x20.
