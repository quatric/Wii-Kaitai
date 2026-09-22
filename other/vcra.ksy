meta:
  id: vcra
  endian: le
  title: Bandai Namco Museum Remix archive (VCRA)
doc: |
  Bandai Namco Museum Remix archive, per lib-vcra.c. Two entry
  layouts exist, selected by whether the word at file offset 0x0C
  is non-zero: a 44-byte entry carrying a CRC, or a 64-byte
  CRC-less entry whose table starts at 0x40. In the CRC-bearing
  variant, the table starts at 0x0C: the word used as the discriminator
  is also the first entry's payload offset. The extractor does not
  verify CRC values. It requires at least one entry, a complete table,
  total_size equal to actual file size, and every payload to begin at
  or after the table and end within the file. Invalid names are replaced
  on extraction with file_NNNN.bin, using the zero-based entry index.

  The nintoolbox writer emits only the 64-byte variant. It places the
  table at 0x40, writes names in the 56-byte area, and aligns the first
  and all subsequent payloads to 32 bytes. The header tail, name padding,
  and inter-payload gaps are zero-filled. These are writer conventions,
  not required by the reader.
seq:
  - id: magic
    contents: "VCRA"
  - id: num_entries
    type: u4
    doc: Number of descriptors in either table variant; must be nonzero.
  - id: total_size
    type: u4
    doc: Declared whole-file size; extractor requires equality with actual size.
  - id: unknown_0c
    type: u4
    doc: Zero selects 64-byte entries; otherwise these are the first 4 bytes of the first 44-byte entry's payload offset.
  - id: unknown_10
    size: 0x40 - 0x10
    if: unknown_0c == 0
    doc: Header tail used only by the 64-byte variant; writer zero-fills it.
  - id: entries
    type: entry_t
    repeat: expr
    repeat-expr: num_entries
    if: unknown_0c == 0
    doc: 64-byte descriptors beginning at file offset 0x40.
instances:
  crc_entries:
    pos: 0x0c
    type: crc_entry_t
    repeat: expr
    repeat-expr: num_entries
    if: unknown_0c != 0
    doc: 44-byte CRC-bearing descriptors beginning at file offset 0x0c.
types:
  entry_t:
    seq:
      - id: offset
        type: u4
        doc: Absolute payload offset; extractor requires it to follow the table.
      - id: size
        type: u4
        doc: Payload length in bytes.
      - id: name
        type: str
        size: 56
        encoding: ASCII
        terminator: 0
        doc: Embedded member path; extractor substitutes a generated name if invalid.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
  crc_entry_t:
    seq:
      - id: offset
        type: u4
        doc: Absolute payload offset; extractor requires it to follow the table.
      - id: size
        type: u4
        doc: Payload length in bytes.
      - id: crc
        type: u4
        doc: Stored CRC value; nintoolbox's extractor does not check it.
      - id: name
        type: str
        size: 32
        encoding: ASCII
        terminator: 0
        doc: Embedded member path; invalid paths get a generated extraction name.
    instances:
      body:
        pos: offset
        size: size
        io: _root._io
