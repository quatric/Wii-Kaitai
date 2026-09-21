meta:
  id: nus3bank
  file-extension: nus3bank
  endian: le
  title: Super Smash Bros. 4 NUS3BANK sound bank
doc: |
  Bandai Namco NUS3 middleware sound bank ("NUS3" + "BANKTOC "), distinct
  from the NUS3AUDIO stream archive despite sharing the "NUS3" magic: a
  bank holds a section table of named 4-byte-tag sections (PROP project
  info, BINF bank name, GRP group names, DTON tone descriptors, TONE tone
  metadata, PACK tone payloads, and optional JUNK padding).

  Reference: nintoolbox project/src/lib-nus3bank.c, itself a clean-room
  C port of KillzXGaming/Smash-Forge's NUS3BANK.cs (MIT licensed).
seq:
  - id: magic
    contents: "NUS3"
  - id: toc_magic
    contents: "BANKTOC "
  - id: len_toc
    type: u4
    doc: Size of the section-descriptor table that follows (starting right after this field).
  - id: num_sections
    type: u4
  - id: toc
    type: toc_entry
    repeat: expr
    repeat-expr: num_sections
    doc: |
      Section directory: tag + payload size only. The real payload
      chunks (each with their own repeated tag+size sub-header) follow
      immediately after the directory, back-to-back and in the same
      order, starting at `payload_base`.
  - id: sections
    type: section_chunk
    repeat: eos
types:
  toc_entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_payload
        type: u4

  section_chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_payload
        type: u4
      - id: payload
        size: len_payload
        type:
          switch-on: tag
          cases:
            '"PROP"': prop_body
            '"BINF"': binf_body
            '"GRP "': named_table_body
            '"DTON"': named_table_body
            '"TONE"': tone_table_body
            _: raw_body

  raw_body:
    seq:
      - id: data
        size-eos: true

  prop_body:
    doc: Project name and build timestamp, both length-prefixed (u1 length including NUL).
    seq:
      - id: unk1
        type: u4
      - id: unk2
        type: u4
      - id: unk3
        type: u2
      - id: unk4
        type: u2
      - id: len_project
        type: u1
      - id: project
        type: str
        size: len_project
        encoding: ASCII

  binf_body:
    doc: Bank display name plus a flags word, 4-byte aligned after the name.
    seq:
      - id: zero_pad
        type: u4
      - id: unk1
        type: u4
      - id: len_name
        type: u1
      - id: name
        type: str
        size: len_name
        encoding: ASCII

  named_table_body:
    doc: "GRP / DTON table: a u4 count followed by that many (offset:u4) entries."
    seq:
      - id: num_entries
        type: u4
      - id: entry_offset
        type: u4
        repeat: expr
        repeat-expr: num_entries

  tone_table_body:
    doc: "TONE table: a u4 count followed by that many (offset:u4) entries into the tone list."
    seq:
      - id: num_entries
        type: u4
      - id: entry_offset
        type: u4
        repeat: expr
        repeat-expr: num_entries

  named_entry:
    doc: |
      Group/tone descriptor entry: a reserved s4, then a length-prefixed
      name (u1 length including NUL, chars, 4-byte aligned).
    seq:
      - id: reserved
        type: u4
      - id: len_name
        type: u1
      - id: name
        type: str
        size: len_name
        encoding: ASCII

  tone_entry:
    doc: |
      One tone: a hash, a named_entry (name), a reserved pair, then the
      payload's (offset, size) into PACK. PACK payloads sit 8 bytes into
      that section's own payload (an 8-byte sub-header precedes them).
    seq:
      - id: hash
        type: u4
      - id: name_entry
        type: named_entry
      - id: reserved
        type: u8
      - id: ofs_pack
        type: u4
      - id: len_pack
        type: u4
