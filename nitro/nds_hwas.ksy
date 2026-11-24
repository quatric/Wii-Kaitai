meta:
  id: nds_hwas
  title: Vicarious Visions DS audio (.hwas)
  file-extension: hwas
  endian: le
doc: |
  Vicarious Visions DS audio (`sawh`: Spider-Man 3, Tony Hawk's Downhill Jam,
  Guitar Hero On Tour). Headerless IMA-ADPCM blocks from 0x200 whose predictor
  and step index are reset to zero at every block (after vgmstream `hwas.c`).
  Mono only.
seq:
  - id: magic
    contents: sawh
  - id: block_size
    type: u4
  - id: sample_rate
    type: u4
  - id: num_channels
    type: u4
  - id: loop_start_offset
    type: u4
  - id: data_offset
    type: u4
  - id: loop_end_offset
    type: u4
