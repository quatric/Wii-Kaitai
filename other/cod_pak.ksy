meta:
  id: cod_pak
  file-extension: pak
  endian: le
  title: Call of Duty (Wii) sound archive PAK0
doc: |
  Call of Duty: Black Ops / Modern Warfare 3 (Wii) sound archive. Members
  carry no names in the format, only a CRC (recovered on extraction as
  the basename `..._0x%08x.dsp`). Each entry's absolute byte offset is
  `entry_offset * multiplier + ofs_data_start`.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid: '"PAK0"'
  - id: salt
    type: u4
    doc: Unknown per-archive value; carried through verbatim, no known meaning.
  - id: num_entries
    type: u4
  - id: multiplier
    type: u4
    doc: Multiplied by an entry's stored offset to get its byte distance from `ofs_data_start`.
  - id: ofs_data_start
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: crc
        type: u4
      - id: offset
        type: u4
        doc: Multiply by the header's `multiplier` and add `ofs_data_start` for the absolute offset.
      - id: size
        type: u4
    instances:
      ofs_body:
        value: _root.ofs_data_start + offset * _root.multiplier
      body:
        io: _root._io
        pos: ofs_body
        size: size
