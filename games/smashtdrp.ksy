meta:
  id: smashtdrp
  endian: be
  title: Super Smash Bros. 4 DRP encrypted container (.drp)
doc: |
  Super Smash Bros. 4 DRP container, per lib-smashtdrp.h (ported
  from KillzXGaming/Smash-Forge DRP.cs). The entire file is word-wise
  obfuscated; do not interpret the raw bytes at 0x16 as a file count.
  The big-endian signed seed at raw offset 0x1c initializes a four-word
  RandomXS state. Each 32-bit raw word is XORed with the next generator
  value and a one-bit chain carried from the prior generator value;
  the resulting word is byte-swapped into the decrypted buffer. The
  decrypted word at offset 0x1c is then replaced with the original seed.
  This procedural cipher is not applied by Kaitai.

  Decryption requires a nonempty input of at least 0x20 bytes whose
  length is divisible by eight. After decryption, the big-endian count
  at 0x16 must be 1..9999, the 0x60-byte records beginning at 0x60 must
  fit, and the first 0x40-byte name must be nonempty printable ASCII
  with a NUL terminator. The decrypted layout is modeled below as a
  standalone type for use with a separately decrypted byte stream.

  Parts follow the entire record table consecutively. The extractor
  takes its part count from the first 16-bit count at record offset
  0x48 (despite the source comment naming the two count halfwords in
  the opposite order). Each selected 32-bit part size includes a
  four-byte big-endian expected output length, then a standard zlib
  stream. The extractor validates part sizes and file bounds, accepts
  decompression only when output is nonzero, below 16 MiB, and exactly
  the expected length, and otherwise saves the compressed bytes without
  the size prefix. Output names use the record name, optional `.partN`,
  and the first four printable decoded bytes as an extension; otherwise
  they use `.bin`. Only extraction is implemented; no re-encryption.
  The descriptor reserves four size words, but the extractor does not
  cap part_count to four before reading them; larger counts can run into
  following descriptor bytes and should not be treated as well-formed.
seq:
  - id: obfuscated_prefix
    size: 0x1c
    doc: Ciphertext prefix; decrypted bytes at 0x16 contain the file count.
  - id: cipher_seed
    type: u4
    doc: Raw big-endian seed at 0x1c, used to initialize the RandomXS cipher.
  - id: obfuscated_remainder
    size-eos: true
    doc: More ciphertext; decryption covers the whole file, not just this tail.
types:
  decrypted_container:
    doc: Parse this type from the fully decrypted buffer, not the raw DRP file.
    seq:
      - id: prefix
        size: 0x16
      - id: file_count
        type: u2
        doc: Number of 0x60-byte records at offset 0x60.
      - id: header_tail
        size: 0x60 - 0x18
      - id: records
        type: record
        repeat: expr
        repeat-expr: file_count
      - id: part_region
        size-eos: true
        doc: Concatenated sized zlib parts in record order.
  record:
    seq:
      - id: name
        type: str
        size: 0x40
        encoding: ASCII
        terminator: 0
        doc: Fixed-width NUL-terminated member name.
      - id: unknown_40
        type: s4
      - id: next_file
        type: s4
        doc: Record-link field not used to locate parts by nintoolbox.
      - id: part_count
        type: u2
        doc: First count halfword at 0x48; extractor uses this as part count.
      - id: other_count
        type: u2
        doc: Second count halfword, ignored by the extractor.
      - id: reserved_4c
        size: 4
      - id: part_sizes
        type: s4
        repeat: expr
        repeat-expr: 4
        doc: Declared total byte lengths for up to four part records.
  part:
    doc: Standalone layout of one size-bounded part from part_region.
    seq:
      - id: expected_size
        type: u4
        doc: Exact uncompressed byte length required for accepted zlib output.
      - id: zlib_stream
        size-eos: true
        doc: Standard zlib bytes; extractor saves these raw on decode failure.
