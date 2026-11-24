meta:
  id: hca
  title: CRI HCA audio
  file-extension: hca
  endian: be
doc: |
  Header chunks (each with its top bit masked, big endian): "HCA\0" {u16
  version, u16 header size}, "fmt\0" {u8 channels, u24 rate, u32 block count, u16
  encoder delay, u16 padding}, "comp"/"dec\0", optional "vbr", "ath", "loop",
  "ciph" (non-zero type = encrypted; key is game specific), "rva", "comm".
seq:
  - id: magic
    size: 4
    doc: '"HCA\0" with the top bits possibly set.'
  - id: version
    type: u2
  - id: header_size
    type: u2
  - id: chunks
    size: header_size - 8
  - id: blocks
    size-eos: true
