meta:
  id: sze
  endian: le
  title: Encrypted SZS/SARC/Zstd container (SZE, F-Zero 99)
doc: |
  Encrypted SZS/SARC/Zstd container used by F-Zero 99 and Switch
  titles, per lib-sze.c. A fixed 32-byte header precedes an encrypted
  payload. Mode 0 uses AES-128-CBC, mode 2 uses AES-128-OFB, and mode 1
  or any other nonzero value uses AES-128-CTR. The payload is not
  decrypted or decompressed by this Kaitai schema.

  The decoder uses its built-in 16-byte key `FZERO99_NST_SZE1` unless a
  caller supplies another key. The IV is the 16 bytes at header offset
  0x10. In CBC mode it decrypts only complete 16-byte blocks; any trailing
  bytes are left as they were. OFB and CTR process the full payload.
  The decoded_size field trims the returned plaintext only when it is
  positive and no larger than the encrypted payload size. Otherwise the
  decoder returns the full payload length; it does not reject the field.
  Inner SZS/SARC/Zstd decoding is a separate step.

  The writer always emits SZE1 and zeroes the word at 0x0c. In CBC mode
  it zero-pads the plaintext to a 16-byte boundary but records the
  unpadded byte count in decoded_size. If no IV is supplied, it derives
  byte i as `(size * 31 + i * 17 + 0x5a) & 0xff`; this deterministic IV
  is a writer behavior, not a property required by the file format.
seq:
  - id: magic
    size: 4
    valid:
      any-of: ['[0x53, 0x5a, 0x45, 0x00]', '[0x53, 0x5a, 0x45, 0x31]']
  - id: decoded_size
    type: u4
    doc: Intended plaintext length; decoder trims only if 1..payload length.
  - id: mode
    type: u4
    doc: 0 = AES-128-CBC, 2 = AES-128-OFB, all other values = AES-128-CTR.
  - id: unknown_0c
    size: 4
    doc: Header word written as zero by nintoolbox; decoder ignores it.
  - id: iv
    size: 16
    doc: Initial vector/counter bytes passed to the selected AES mode.
  - id: payload
    size-eos: true
    doc: Encrypted bytes; CBC writer may include zero-padding in plaintext.
