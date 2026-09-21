meta:
  id: txtg
  endian: le
  title: Next Level Games Texture To Go (.txtg / 6PK0)
doc: |
  Next Level Games "Texture To Go" texture, per lib-txtg.c.
seq:
  - id: header_size
    type: u2
    doc: >-
      Byte offset of the first surface table, usually 0x50.  It must be at
      least 0x46 for the fixed fields through format to fit.
  - id: version
    type: u2
    doc: Usually 0x11.
  - id: magic
    contents: "6PK0"
    doc: TXTG signature at offset 0x04.
  - id: width
    type: u2
    doc: Base texture width in pixels.
  - id: height
    type: u2
    doc: Base texture height in pixels.
  - id: depth
    type: u2
    doc: >-
      Array/depth count.  A stored zero is interpreted as one array level by
      the reference extractor.
  - id: mip_count
    type: u1
    doc: >-
      Number of mip levels.  A stored zero is interpreted as one level by the
      reference extractor.
  - id: unknown1
    type: u1
    doc: Unknown byte at 0x0f; preserve it.
  - id: unknown2
    type: u1
    doc: Unknown byte at 0x10; preserve it.
  - id: padding
    type: u1
    doc: Padding/unknown byte at 0x11; preserve it.
  - id: format_flag
    type: u1
    doc: Format-related flag byte at 0x12; semantics are not established.
  - id: format_setting
    type: u4
    doc: Format setting or reserved u32 at 0x13; preserve it.
  - id: unknown_17
    size: 0x44 - 0x17
    doc: Unidentified fixed header bytes at 0x17..0x43.
  - id: format
    type: u2
    doc: 16-bit texture format identifier used by the extractor for reporting.
  - id: unknown_46
    size: header_size - 0x46
    doc: Variable header extension between offset 0x46 and header_size.
  - id: surface_keys
    type: surface_key
    repeat: expr
    repeat-expr: total_surfaces
    doc: >-
      First surface table: one array-level/mip-level key per stored surface.
  - id: surface_descriptors
    type: surface_descriptor
    repeat: expr
    repeat-expr: total_surfaces
    doc: >-
      Second surface table, parallel to surface_keys.  Entry i supplies the
      byte size for the array/mip identity at surface_keys[i].
  - id: surface_data
    size-eos: true
    doc: >-
      Concatenated surface payloads.  Descriptor-sized payloads begin at
      surface_data_offset and each next payload is aligned upward to 16 bytes;
      the table does not store independent offsets.
instances:
  effective_depth:
    value: "depth != 0 ? depth : 1"
    doc: Depth/array count after applying the format's zero-means-one rule.
  effective_mip_count:
    value: "mip_count != 0 ? mip_count : 1"
    doc: Mip count after applying the format's zero-means-one rule.
  total_surfaces:
    value: effective_depth * effective_mip_count
    doc: >-
      Number of entries in each surface table.  The reference extractor
      rejects totals above 1000.
  surface_data_offset:
    value: header_size + total_surfaces * 12
    doc: >-
      Offset immediately following the 4-byte key and 8-byte descriptor
      tables; this is the start of the first raw surface payload.
types:
  surface_key:
    seq:
      - id: array_level
        type: u2
        doc: Array/depth layer represented by this surface.
      - id: mip_level
        type: u1
        doc: Mip level represented by this surface.
      - id: unknown
        type: u1
        doc: Unknown per-surface key byte; preserve it.
  surface_descriptor:
    seq:
      - id: size
        type: u4
        doc: >-
          Raw byte size of the matching surface payload, excluding its
          following 16-byte alignment padding.
      - id: unknown
        type: u4
        doc: Unknown per-surface descriptor value; preserve it.
