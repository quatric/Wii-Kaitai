meta:
  id: smashtdrp
  endian: be
  title: Super Smash Bros. 4 DRP encrypted container (.drp)
doc: |
  Super Smash Bros. 4 DRP container, per lib-smashtdrp.h (ported
  from KillzXGaming/Smash-Forge DRP.cs). The payload is obfuscated
  with a seeded xorshift stream cipher (seed at 0x1C) chained
  through the words, so only the fixed unencrypted header fields
  used to locate the seed and file-table shape are modeled; the
  decrypted file table (0x40-byte name + unknowns + 4 part sizes per
  record, at a fixed 0x60 offset once decrypted) and its zlib-
  compressed parts are extract-only in the reference tool and are
  not modeled here.
seq:
  - id: unknown_00
    size: 0x16
  - id: file_count
    type: u2
  - id: unknown_18
    size: 0x1c - 0x18
  - id: cipher_seed
    type: u4
  - id: encrypted_body
    size-eos: true
