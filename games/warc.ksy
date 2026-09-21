meta:
  id: warc
  file-extension: warc
  endian: be
  title: Game & Wario WARC archive
doc: |
  Nintendo / Monster Games archive container used by Game & Wario (Wii U).
  It stores a file-record table, an auxiliary 16-byte-record table, padded
  folder and basename strings, then file data. Files are addressed by a common
  folder prefix and a basename rather than by offsets into a pathname table.

  nintoolbox's reader verifies the 64-byte minimum size and magic, limits
  `num_files` to 0x100000 and `num_folders` to 0x10000, bounds-checks the
  file and auxiliary tables, NUL-terminates and four-byte-aligns every name,
  and only exposes a file whose stored `offset + size` remains inside the input.
  It uses the first folder string as the prefix; subsequent folder strings
  are consumed but have no currently known semantic use. The writer emits
  zero in all unknown/reserved fields, one folder only when every input path
  shares the same directory, and `num_entries == num_files`.

  A retail Game & Wario Bmp.warc is 106,880 bytes and extracts to 93
  non-empty bitmap members. The companion Script.warc.fzip retail sample
  inflates to a 771,575-byte WARC archive with 241 non-empty script members.
  nintoolbox retains both fixtures in `tests/fixtures/`. FZIP may wrap WARC,
  but WARC itself is not compressed.
seq:
  - id: magic
    contents: "WARC"
    doc: ASCII magic signature 'WARC' (0x57415243)
  - id: dummy1
    type: u4
    doc: Unknown header word at 0x04. The nintoolbox writer emits zero; a
      retail Bmp.warc uses 4, so it must not be treated as a constant.
  - id: zero
    type: u4
    doc: Unknown header word at 0x08. The nintoolbox writer emits zero.
  - id: warc_size
    type: u4
    doc: |
      Declared total archive size, written as the final file length by
      nintoolbox. Its reader does not currently compare this value to EOF.
  - id: info_size
    type: u4
    doc: |
      Absolute offset immediately after the padded folder and filename
      strings; equivalently, the first byte available to file payloads in the
      canonical writer. The reader reaches the same boundary by walking names.
  - id: num_folders
    type: u2
    doc: Number of four-byte-aligned, NUL-terminated folder strings.
  - id: num_files
    type: u2
    doc: Number of 32-byte file records and filename strings.
  - id: reserved
    type: u4
    repeat: expr
    repeat-expr: 8
    doc: Eight unknown words at 0x18 through 0x37. Canonical files write zero;
      retail files demonstrate that this region can contain non-zero data.
  - id: num_entries
    type: u4
    doc: Number of auxiliary entry records, excluding the extra trailing
      record. The writer sets this equal to `num_files`.
  - id: dummy2
    type: u4
    doc: Unknown header word at 0x3c; emitted as zero by the writer.
  - id: files
    type: file_entry
    repeat: expr
    repeat-expr: num_files
  - id: entries
    type: entry_record
    repeat: expr
    repeat-expr: num_entries + 1
    doc: Auxiliary 16-byte records. Their contents are retained verbatim;
      nintoolbox consumes them only to locate the following name strings.
  - id: folders
    type: aligned_string
    repeat: expr
    repeat-expr: num_folders
    doc: Folder-prefix strings. The reader joins only the first prefix to
      each filename; all strings are still parsed to preserve stream position.
  - id: filenames
    type: aligned_string
    repeat: expr
    repeat-expr: num_files
    doc: Basenames paired in order with `files` records.

types:
  file_entry:
    seq:
      - id: dummy_a
        type: u4
        repeat: expr
        repeat-expr: 5
        doc: Five unknown words at offsets 0x00 through 0x13 of this record.
      - id: size
        type: u4
        doc: Byte length of this file's payload.
      - id: dummy_b
        type: u4
        doc: Unknown word at offset 0x18 of this record.
      - id: offset
        type: u4
        doc: |
          File-data offset as written by the canonical v0 writer, where it is
          absolute from the beginning of the WARC container. A retail Bmp.warc
          has `dummy1 == 4` and values that do not directly identify every
          payload, so v4 offset translation is not yet established. This is
          deliberately exposed as a scalar rather than a payload slice whose
          position is not proven for both observed layouts.

  entry_record:
    seq:
      - id: dummy_c
        type: u4
        doc: Unknown auxiliary-record word at offset 0x00.
      - id: flags1
        type: u2
        doc: Unknown auxiliary-record halfword at offset 0x04.
      - id: flags2
        type: u2
        doc: Unknown auxiliary-record halfword at offset 0x06.
      - id: dummy_d
        type: u4
        doc: Unknown auxiliary-record word at offset 0x08.
      - id: dummy_e
        type: u4
        doc: Unknown auxiliary-record word at offset 0x0c.

  aligned_string:
    seq:
      - id: value
        type: strz
        encoding: ASCII
        doc: NUL-terminated ASCII string.
      - id: padding
        size: (4 - (_io.pos % 4)) % 4
        doc: Zero-filled alignment bytes in canonical files, bringing the next
          string or payload boundary to a four-byte offset.
