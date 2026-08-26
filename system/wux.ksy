meta:
  id: wux
  file-extension: wux
  endian: le
  title: Wii U disc image, sparse (WUX)
doc: |
  The sparse container `wiimms-iso-tools-plus` reads and writes for Wii U
  disc images (WUD). Not a compression in the usual sense: every sector's
  payload is stored verbatim, but a sector whose content is byte-identical
  to one already stored is not stored again -- `index` just points every
  image sector at whichever stored sector holds its bytes. A retail 25 GB
  WUD is mostly encrypted data plus huge runs of identical padding, which
  is what makes this worth doing at all; no cryptographic key is needed
  for the conversion, since it never touches the payload's meaning, only
  which bytes repeat.

  `data_offset` -- where the stored sectors begin -- is not a header
  field. It is computed from the header size and the index table's own
  length, rounded up to the next `sector_size` boundary: `ceil((0x20 +
  n_index * 4) / sector_size) * sector_size`, where `n_index =
  ceil(image_size / sector_size)`. Both formulas come directly from
  `wiimms-iso-tools-plus`'s own reader and writer (`lib-wux.c`), which
  compute them identically for reading and writing.

  ## Validated against

  A synthetic 10-sector image built by hand, with sector 7 made a
  byte-identical duplicate of sector 3, converted to this format,
  and read back -- both by this definition and independently by `wit
  XINFO`/`XCONVERT`, from the real `wiimms-iso-tools-plus` binary itself.
  `wit` reported "9 of 10 stored" (correctly deduplicating sector 7
  against sector 3) and reconstructed the original 10-sector image byte
  for byte when converted back to WUD -- confirming the header, the
  index table and `data_offset`'s formula all independently of anything
  this definition itself computes.
seq:
  - id: magic0
    contents: [0x57, 0x55, 0x58, 0x30]
    doc: '`WUX0`.'
  - id: magic1
    contents: [0x2e, 0xd0, 0x99, 0x10]
    doc: |
      A second, fixed magic word with no known meaning of its own --
      present, unexplained, and checked by the real reader regardless.
  - id: sector_size
    type: u4
    doc: 0x8000 in every file `wiimms-iso-tools-plus`'s own writer produces.
  - id: reserved
    type: u4
    doc: Always 0; unused by the real reader.
  - id: image_size
    type: u8
    doc: Size of the reconstructed (uncompressed) disc image, in bytes.
  - id: unknown
    size: 8
    doc: Always 0; unused by the real reader.
instances:
  num_sectors:
    value: (image_size + sector_size - 1) / sector_size
    doc: One index entry per sector of the reconstructed image.
  index:
    pos: 0x20
    type: u4
    repeat: expr
    repeat-expr: num_sectors
    doc: |
      `index[i]` is which *stored* sector (not file offset) holds image
      sector `i`'s bytes -- look up `stored_sectors[index[i]]` for the
      data, not `index[i]` itself as a position.
  data_offset:
    value: >-
      (0x20 + num_sectors * 4 + sector_size - 1) / sector_size * sector_size
    doc: |
      Rounds the index table's end up to the next `sector_size` boundary.
      Not stored anywhere in the file -- both the real reader and this
      definition compute it the same way from `num_sectors` and
      `sector_size` alone.
  num_stored_sectors:
    value: >-
      index.max + 1
    doc: |
      Sectors are stored in first-use order and referenced by a dense
      0-based index, so the highest value appearing in `index` is always
      exactly one less than how many are actually stored -- there is no
      separate stored-count field.
  stored_sectors:
    pos: data_offset
    size: sector_size
    repeat: expr
    repeat-expr: num_stored_sectors
    doc: |
      Every unique sector's real bytes, once each, in the order they were
      first encountered while writing -- not in image order, and not
      addressable by image sector number directly (use `index` first).
