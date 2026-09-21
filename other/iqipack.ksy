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
seq:
  - id: magic
    contents: "PACK"
  - id: version
    type: u4
    doc: Usually 1.
  - id: unknown1
    size: 0x0c
  - id: header_size
    type: u4
    doc: Size of the encrypted header block that follows; must equal `size2`.
  - id: size2
    type: u4
    doc: Duplicate of `header_size`.
  - id: unknown2
    size: 0x0c
  - id: encrypted_header
    size: header_size
    doc: |
      XXTEA-encrypted directory: once decrypted (key derived from the
      literal string "header"), it holds a u32 asset count followed by
      that many `directory_entry` records.
types:
  directory_entry:
    doc: One record of the decrypted header block; not directly readable from the raw file.
    seq:
      - id: len_path
        type: u4
      - id: path
        type: str
        size: len_path
        encoding: UTF-8
      - id: len_body
        type: u4
      - id: len_body2
        type: u4
        doc: Duplicate of `len_body`.
      - id: ofs_body
        type: u4
        doc: Offset relative to the end of the header block (file offset 0x28 + header_size).
      - id: reserved
        size: 0x10
