meta:
  id: arcv
  file-extension: arc
  endian: le
  title: Namco / Tose ARCV archive
doc: |
  A flat, unnamed-member archive used by Namco/Tose Wii titles; shares
  the .arc extension with several unrelated formats (RARC, Brawl PAC,
  etc.), so callers must check the `ARCV` magic before trusting this.
  Members carry no on-disk name -- only their ordinal position, which
  extractors surface as `file_%04u<ext>` -- and a per-member CRC32.
seq:
  - id: magic
    contents: "ARCV"
  - id: num_entries
    type: u4
  - id: len_file
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
      - id: crc32
        type: u4
        doc: zlib crc32 of the member's raw bytes.
    instances:
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
