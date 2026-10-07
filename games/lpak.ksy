meta:
  id: lpak
  title: 2XL Games LPAK resource pack (.PAK)
  file-extension: pak
  endian: le
doc: |
  2XL Games' RIFF-based resource pack (SCORE International Baja 1000, Wii:
  `ANIMS.PAK`, `BAJAINF.PAK`, `PARTICLES.PAK`, `PERMTEX.PAK`, ...). Verified
  on four retail files (959 members).

  The file starts with a `u4` payload size, then a RIFF container whose form
  type is `LPAK`. Each member is one `LIST` chunk (form `LDAT`) holding:

  * `dir ` -- asset bookkeeping (CRC and offsets); not needed to unpack.
  * `file` -- `u4 type_hash`, `u4 unpacked_size`, `u4 header_size H`, then
    `(H - 12) / 4` `u4` block start offsets and the data: a run of zlib
    streams, each inflating to 0x4000 bytes (the last one fewer), so
    `(H - 12) / 4 + 1` blocks. Members without a zlib header (first byte
    0x78) are stored as is.
  * `str ` -- NUL-separated path components, the last being the file name.

  Chunk bodies are padded to an even length.
seq:
  - id: payload_size
    type: u4
  - id: riff_magic
    contents: 'RIFF'
  - id: riff_size
    type: u4
  - id: form_type
    contents: 'LPAK'
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: id
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: id
          cases:
            '"LIST"': list_body
      - id: pad
        size: size & 1
  list_body:
    seq:
      - id: form_type
        type: str
        size: 4
        encoding: ASCII
        doc: '`LDAT` for member lists.'
      - id: chunks
        type: sub_chunk
        repeat: eos
  sub_chunk:
    seq:
      - id: id
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: id
          cases:
            '"file"': file_body
            '"str "': path_body
      - id: pad
        size: size & 1
  file_body:
    seq:
      - id: type_hash
        type: u4
      - id: unpacked_size
        type: u4
      - id: header_size
        type: u4
        doc: Size of this header including the three words above and the offset table.
      - id: block_offsets
        type: u4
        repeat: expr
        repeat-expr: (header_size - 12) / 4
        doc: Start offsets of the zlib blocks, relative to the `file` chunk body.
      - id: data
        size-eos: true
        doc: |
          Concatenated zlib streams, each inflating to 0x4000 bytes (last
          block shorter), or the raw member when no zlib header is present.
  path_body:
    seq:
      - id: components
        type: strz
        encoding: ASCII
        repeat: eos
        doc: Directory components followed by the file name; empty tails are dropped.
