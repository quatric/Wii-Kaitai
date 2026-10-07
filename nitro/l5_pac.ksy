meta:
  id: l5_pac
  title: Level-5 / Armor Project PAC archive (Dragon Quest IX)
  file-extension: pac
  endian: le
doc: |
  Level-5 / Armor Project PAC archive as used by Dragon Quest IX on
  Nintendo DS (`.pac` and `.dat`). It has no magic and no member count: it is
  a chain of 80-byte (0x50) member headers, each followed immediately by its
  payload, and the next header sits `alloc_size` bytes after the previous one
  (a 16-byte-aligned allocation stride).

  The archive ends at a sentinel or the end of the file:

  * `file_size == 0xffffffff` or `alloc_size == 0xffffffff` (sentinel record);
  * `header_length != 0x50` or `alloc_size == 0`;
  * the entry name is empty, or only padding is left.

  The name field is NUL-terminated ASCII / Shift-JIS up to about 36 bytes,
  followed by memory / tool scratch metadata that nintoolbox ignores.
seq:
  - id: members
    type: member
    repeat: until
    repeat-until: _.is_last or _io.eof
types:
  member:
    seq:
      - id: name_block
        size: 0x40
        type: name_block
        doc: NUL-terminated name followed by tool scratch bytes.
      - id: header_length
        type: u4
        doc: Always 0x50.
      - id: file_size
        type: u4
        doc: Uncompressed payload length; `0xffffffff` in the terminator.
      - id: alloc_size
        type: u4
        doc: Stride from this header to the next one; 0 or `0xffffffff` ends the chain.
      - id: flags
        type: u4
        doc: Engine flags / scratch address.
      - id: payload
        size: file_size
        if: not is_last
      - id: padding
        size: alloc_size - 0x50 - file_size
        if: not is_last
    instances:
      is_last:
        value: >-
          header_length != 0x50 or alloc_size == 0 or file_size == 0xffffffff
          or alloc_size == 0xffffffff
  name_block:
    seq:
      - id: name
        type: strz
        encoding: ASCII
        doc: |
          Name up to the first NUL (Shift-JIS in some titles; ASCII is used
          so the type compiles everywhere).
      - id: scratch
        size-eos: true
