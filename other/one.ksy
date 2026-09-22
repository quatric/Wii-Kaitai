meta:
  id: one
  endian: be
  title: Sonic Storybook ONE archive (Sonic and the Secret Rings / Black Knight)
doc: |
  Sonic Team Storybook-series ".one" archive, as written by
  CreateONEArchive() in lib-one.c. A fixed 16-byte header followed by
  a flat table of 48-byte entries: 32 name bytes, a reserved 32-bit
  word, absolute PRS-body offset, compressed size, and decompressed size.
  Member data is Sonic Team's PRS-variant LZ stream, not decoded here.

  The reader requires the table offset to be 16, a nonzero entry count,
  a data_start at or beyond the complete table, and marker 0 (Secret Rings)
  or 0xffffffff (Black Knight). Each entry must have a valid nonempty path,
  an in-file compressed payload beginning at or after data_start, and a
  nonzero decoded length. The decoded PRS stream must end with its explicit
  end token after producing exactly decompressed_size bytes.

  PRS control bits are consumed least-significant-bit first. A 1 bit emits
  a literal byte; a 0,0 prefix selects a one-byte negative-offset match
  with two following length bits (length 2..5), and 0,1 selects a little-
  endian 16-bit match word. In that word, the upper 13 bits encode an
  offset from -8192 to -1 and the lower three bits encode length 3..9;
  a zero length code reads an extra byte and uses byte+1 instead. A zero
  match word after 0,1 ends the stream. This is a description of the
  compressed body, not a claim that this schema expands it.

  The writer puts the table directly at 16, starts payloads immediately
  after it, uses no inter-payload alignment, zeros the reserved entry word,
  and compresses every member. It accepts names of 1..32 bytes; a 32-byte
  name need not have an on-disk NUL. Newly created archives use marker 0,
  but replacing an existing output can preserve its valid marker.
seq:
  - id: num_entries
    type: u4
    doc: Number of 48-byte descriptors; must be nonzero for nintoolbox.
  - id: table_offset
    type: u4
    doc: Absolute descriptor-table offset; nintoolbox requires 16.
  - id: data_start
    type: u4
    doc: Earliest permitted payload offset; writer uses 16 + num_entries * 48.
  - id: marker
    type: u4
    doc: 0 = Secret Rings, 0xffffffff = Black Knight.
instances:
  entries:
    pos: table_offset
    type: entry
    repeat: expr
    repeat-expr: num_entries
    doc: Descriptor array at the header's absolute table offset.
types:
  entry:
    seq:
      - id: name
        type: str
        size: 32
        encoding: ASCII
        terminator: 0
        doc: Member path; occupies all 32 bytes when not NUL-terminated.
      - id: reserved
        type: u4
        doc: Unused by extractor; zero in nintoolbox-produced archives.
      - id: data_offset
        type: u4
        doc: Absolute offset of the PRS-compressed payload.
      - id: compressed_size
        type: u4
        doc: Stored PRS stream size in bytes.
      - id: decompressed_size
        type: u4
        doc: Expected PRS output size; extractor requires a positive value.
    instances:
      body:
        pos: data_offset
        size: compressed_size
        io: _root._io
        doc: Raw PRS stream, including its end token; not expanded by this parser.
