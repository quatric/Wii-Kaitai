meta:
  id: yay0
  endian: be
  title: Nintendo Yay0 compressed stream
doc: |
  Nintendo Yay0 LZ-style compressed stream used by first-party Nintendo 64,
  GameCube, and Wii software. The stream has a fixed 16-byte header followed
  by three independently addressed sections: big-endian control words, a
  two-byte back-reference table, and literal/extended-length bytes.

  nintoolbox's decoder reads control bits most-significant-bit first. A set
  bit consumes one literal byte from `chunk_data`; a clear bit consumes a
  big-endian 16-bit link. The link's low 12 bits encode a backward distance
  minus one. Its high nibble encodes a copy length minus two when non-zero;
  when zero, the next chunk-data byte gives a copy length minus 18. Thus
  ordinary matches cover lengths 3..17, extended matches 18..273, and all
  match distances are 1..4096 bytes. Decoding stops exactly after producing
  `uncompressed_size` bytes, not at end of any compressed section.

  The offsets are trusted only after each read is bounds-checked: masks must
  be available in four-byte units, links in two-byte units, literal and
  extended-length bytes in the input, and a match may neither refer before
  output byte zero nor exceed the declared output size. The companion encoder
  emits canonical section order: masks at 0x10, links at `link_table_offset`,
  and chunks at `chunk_data_offset`.
seq:
  - id: magic
    contents: "Yay0"
    doc: ASCII signature `Yay0` (0x59617930).
  - id: uncompressed_size
    type: u4
    doc: Exact number of bytes the decoder must produce.
  - id: link_table_offset
    type: u4
    doc: Absolute byte offset of the two-byte back-reference section. The
      canonical encoder places the control-word section between 0x10 and here.
  - id: chunk_data_offset
    type: u4
    doc: Absolute byte offset of the literal and extended-length byte section.
  - id: body
    size-eos: true
    doc: Raw stream body retained for tools that implement the control-bit
      decode loop described above.
instances:
  control_words:
    pos: 16
    size: link_table_offset - 16
    doc: Big-endian 32-bit control words, consumed most-significant bit first.
  link_table:
    pos: link_table_offset
    size: chunk_data_offset - link_table_offset
    doc: Big-endian 16-bit match descriptors selected by clear control bits.
  chunk_data:
    pos: chunk_data_offset
    size-eos: true
    doc: Literal bytes selected by set control bits and extension bytes for
      zero-length-nibble link descriptors.
