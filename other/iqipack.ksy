meta:
  id: iqipack
  file-extension: pak
  endian: le
  title: NVIDIA Shield "iQiyi" PACK container
doc: |
  NVIDIA Shield iQiyi PAK container. A fixed 0x28-byte header is followed
  by an XXTEA-encrypted header block (per-file directory) and then the
  asset data area; each asset is itself independently XXTEA-encrypted,
  keyed off its own relative path string, length and offset (see
  lib-iqipack.c's `GenerateKey`/`DecryptAsset` -- the encryption itself is
  algorithmic, not structural, so it is not modeled here). Ported from
  lib-iqipack.c's `iqipack_header_t`/`IsIQIPack`/`ExtractIQIPack`.

  The encrypted directory starts immediately after the 0x28-byte header;
  asset offsets are relative to the first byte after that directory, not
  to file start. Detection requires PACK magic, nonzero header_size,
  matching size2, and enough bytes for the encrypted directory. The
  version and reserved bytes are not validated. The plaintext directory
  layout is modeled below as decrypted_directory, but this schema does
  not decrypt encrypted_header or instantiate that type automatically.

  Key derivation starts with a 32-bit hash of the path bytes: seed 0x1505,
  then for each byte hash = hash * 33 XOR byte, wrapping at 32 bits. Let
  base = total_encrypted_length XOR chunk_offset XOR hash. The four XXTEA
  key words are base AND, respectively, 0xa0d0ffb0, 0x81230089,
  0x12159842, and 0xff78f3c7. The directory uses the six bytes `header`
  as its path. Assets use their exact on-disk path bytes; changing the path
  changes the key. Decryption processes independent 0x2000-byte chunks,
  passing each chunk's offset within the asset to key derivation. It uses
  6 + floor(52 / word_count) standard XXTEA rounds on complete little-
  endian 32-bit words; 0..3 trailing bytes in a chunk are left unchanged,
  and chunks of at most one word are not transformed.

  The extractor stops on malformed or truncated plaintext directory
  records and may still return success with fewer files than num_assets.
  It does not compare len_body2 with len_body, validate the 16 reserved
  bytes, or sanitize relative paths before writing them. It skips assets
  whose seek or full-length read fails. These are implementation behaviors,
  not endorsements of malformed input or unsafe paths.
seq:
  - id: magic
    contents: "PACK"
  - id: version
    type: u4
    doc: Usually 1; ignored by nintoolbox's detector and extractor.
  - id: unknown1
    size: 0x0c
    doc: Reserved header bytes; reader does not inspect them.
  - id: header_size
    type: u4
    doc: Size of the encrypted header block that follows; must equal `size2`.
  - id: size2
    type: u4
    doc: Duplicate of header_size; equality is required for detection.
  - id: unknown2
    size: 0x0c
    doc: Reserved header bytes; reader does not inspect them.
  - id: encrypted_header
    size: header_size
    doc: |
      XXTEA-encrypted directory: once decrypted (key derived from the
      literal string "header"), it holds a u32 asset count followed by
      that many directory_entry records. The plaintext layout is modeled
      by decrypted_directory for use on a separately decrypted buffer.
types:
  decrypted_directory:
    doc: Layout of the encrypted_header bytes after XXTEA decryption.
    seq:
      - id: num_assets
        type: u4
        doc: Intended number of directory records.
      - id: entries
        type: directory_entry
        repeat: expr
        repeat-expr: num_assets
        doc: Variable-length records, terminated by count rather than a sentinel.
  directory_entry:
    doc: One record of the decrypted header block; not directly readable from the raw file.
    seq:
      - id: len_path
        type: u4
        doc: Nonzero byte length of the following relative path.
      - id: path
        type: str
        size: len_path
        encoding: UTF-8
        doc: Exact path bytes are needed for the asset's decryption key.
      - id: len_body
        type: u4
        doc: Encrypted asset byte length.
      - id: len_body2
        type: u4
        doc: Nominal duplicate of len_body; extractor ignores it.
      - id: ofs_body
        type: u4
        doc: Offset relative to the end of the header block (file offset 0x28 + header_size).
      - id: reserved
        size: 0x10
        doc: Reader-ignored record tail, conventionally padding.
