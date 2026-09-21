meta:
  id: sze
  endian: le
  title: Encrypted SZS/SARC/Zstd container (SZE, F-Zero 99)
doc: |
  Encrypted SZS/SARC/Zstd container used by F-Zero 99 and Switch
  titles, per lib-sze.c. AES-128 CBC (mode 0) or CTR (other) over
  the payload after this fixed 32-byte header; the encrypted
  payload itself is not decoded here.
seq:
  - id: magic
    size: 4
    valid:
      any-of: ['[0x53, 0x5a, 0x45, 0x00]', '[0x53, 0x5a, 0x45, 0x31]']
  - id: decoded_size
    type: u4
  - id: mode
    type: u4
    doc: 0 = AES-128-CBC, else AES-128-CTR.
  - id: unknown_0c
    size: 4
  - id: iv
    size: 16
  - id: payload
    size-eos: true
