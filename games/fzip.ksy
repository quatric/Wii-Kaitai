meta:
  id: fzip
  file-extension: fzip
  endian: be
  title: Game & Wario FZIP compressed container
doc: |
  The Game & Wario (Wii U) FZIP compression wrapper. It is exactly an
  8-byte big-endian header followed by one compressed byte stream; it is
  unrelated to the ZIP archive format.

  The retail file `content/Common/Script.warc.fzip` from Game & Wario
  (USA, En/Fr/Es) is 76,945 bytes. Its header declares 771,575 output
  bytes, and inflating its payload produces a WARC archive of exactly that
  length containing 241 non-empty Script/*.sttxt members. nintoolbox keeps
  this file verbatim as `tests/fixtures/fzip_wiiu_game_and_wario_script.warc.fzip`.

  The writer in nintoolbox emits a normal zlib stream (RFC 1950/1951) and
  records the input length in `uncompressed_size`. Its decoder first tries
  zlib/gzip auto-detection and, if that fails, tries raw RFC 1951 DEFLATE.
  Kaitai's built-in `process: zlib` covers the writer's zlib form, but not
  the decoder's gzip or raw-DEFLATE compatibility paths. Consumers needing
  those paths must inflate `compressed_payload_raw` with the appropriate
  wrapper outside this definition.

  `uncompressed_size` is not a checksum or an enforced framing boundary:
  nintoolbox uses it as the initial output-buffer capacity, grows that buffer
  when necessary, and returns the decoder's actual output length without
  comparing the two values. Do not use it as proof that the payload is valid.

  FZIP wraps WARC archives, BFRES models, BFLIM textures, layouts, and
  message files in Game & Wario assets.
seq:
  - id: magic
    contents: "FZIP"
    doc: ASCII magic signature 'FZIP' (0x465A4950)
  - id: uncompressed_size
    type: u4
    doc: |
      Big-endian advertised decompressed length. The canonical writer sets
      this to the input length. nintoolbox caps it at 512 MiB before using it
      as an allocation hint, but accepts a successfully inflated stream even
      when its actual length differs.
  - id: compressed_payload
    size-eos: true
    process: zlib
    doc: |
      Remaining bytes interpreted as a zlib-wrapped DEFLATE stream by Kaitai.
      This is the form emitted by nintoolbox. See `compressed_payload_raw`
      for the original bytes and the format-level documentation for gzip and
      raw-DEFLATE compatibility forms that Kaitai cannot select dynamically.
instances:
  compressed_payload_raw:
    pos: 8
    size-eos: true
    doc: |
      The compressed bytes before Kaitai's zlib transform. Preserve these when
      testing a payload with a gzip or raw-DEFLATE decoder.
