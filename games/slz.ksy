meta:
  id: slz
  title: Namco Tales of SLZ (Okumura LZSS)
  file-extension: slz
  endian: le
doc: |
  Tales of (Wii) `*.slz`. The payload is Okumura LZSS (LSB-first flag bytes,
  4096-byte zero-filled ring, start 0xfee, 12-bit position + 4-bit length-3);
  usually an FPS4 archive once decompressed.
seq:
  - id: type
    type: u1
    doc: 1.
  - id: compressed_size
    type: u4
  - id: decompressed_size
    type: u4
  - id: stream
    size-eos: true
