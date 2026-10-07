meta:
  id: goliath_pkz_v6
  title: Goliath "GS version 6.64" package (The Amazing Spider-Man, Wii)
  file-extension: pkz
  endian: be
doc: |
  The older dialect of the Goliath engine's hierarchical chunk package
  (compare `goliath_pkz.ksy`, the 16-byte "GS version 9.x" dialect of
  Skylanders). Differences: the chunk header is 12 bytes (no `size_hi` word),
  chunk ids do *not* carry the high bit (the root is id 1), and every record
  field is shifted down by 4:

  * name records (id `0x138e`) hold the hash at 0, a constant 4 at +4 and the
    name string at **0x18** (0x1c in v9);
  * texture headers (id `0x197`) are 0x2c bytes (0x30 in v9).

  Texture pixels are *not* in document order in this dialect: each payload sits
  in a `0x26` pool wrapper with its own name record, and the hash in that record
  equals the one in the resource wrapper that owns the header. nintoolbox pairs
  headers and payloads by that hash. The package is usually reached through
  the block-zlib wrapper in `goliath_pkz_block.ksy`.
seq:
  - id: root
    type: chunk
types:
  chunk:
    seq:
      - id: id
        type: u4
        doc: No high bit in this dialect; the root is 1.
      - id: version
        type: u2
      - id: has_children
        type: u2
        doc: 0 = opaque payload, 1 = run of child chunks (never above 1).
      - id: size
        type: u4
        doc: Payload length excluding this 12-byte header.
      - id: children
        size: size
        type: chunk_run
        if: has_children == 1
      - id: payload
        size: size
        if: has_children == 0
  chunk_run:
    seq:
      - id: chunks
        type: chunk
        repeat: eos
  texture_header:
    doc: Body of an id `0x197` chunk.
    seq:
      - id: height
        type: u4
      - id: width
        type: u4
      - id: mipmaps_raw
        type: u4
        doc: Low byte is the mip level count.
      - id: format
        type: u4
        doc: 3 = CMPR mip chain; 4 = CMPR mip chain followed by an I8 alpha mip chain.
      - id: rest
        size-eos: true
  resource_name_record:
    doc: Body of an id `0x138e` chunk (first child of an id `0x138d` resource wrapper).
    seq:
      - id: hash
        type: u4
        doc: Ties the texture header to its pixel payload.
      - id: constant_4
        type: u4
      - id: unknown
        size: 16
      - id: name
        type: strz
        encoding: ASCII
        size: 64
