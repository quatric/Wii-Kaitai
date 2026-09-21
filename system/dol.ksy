meta:
  id: wii_dol
  title: Nintendo GameCube / Wii DOL executable (header)
  file-extension: dol
  endian: be
doc: |
  The 0x100-byte header of a DOL: file offsets, load addresses and sizes for up to seven
  text and eleven data sections, the BSS range and the entry point. Unused sections have
  size 0. Addresses are virtual addresses (0x80000000 based), which is what every
  address quoted in this repository refers to.

  Channels (`00000001.app` in most WADs, or the boot content named by the TMD) are plain
  DOLs, except where a title wraps its main program in LZ11: the Today & Tomorrow Channel
  stores content 1 as an LZ11 stream (`11` + 24-bit little-endian size) that its boot
  loader (content 0x0b) expands; decompress it first, then parse.
seq:
  - id: text_offsets
    type: u4
    repeat: expr
    repeat-expr: 7
    doc: >-
      File offsets of the seven loadable instruction (text) sections.  Entry
      i is paired with text_addresses[i] and text_sizes[i]; an unused slot
      has a zero size and must not be treated as a section at file offset 0.
  - id: data_offsets
    type: u4
    repeat: expr
    repeat-expr: 11
    doc: >-
      File offsets of the eleven loadable data sections.  Entry i is paired
      with data_addresses[i] and data_sizes[i].
  - id: text_addresses
    type: u4
    repeat: expr
    repeat-expr: 7
    doc: >-
      Runtime virtual addresses to which the corresponding text sections are
      copied before execution.  These are PowerPC addresses, normally in the
      0x80000000-based MEM1 address space, not offsets into the DOL file.
  - id: data_addresses
    type: u4
    repeat: expr
    repeat-expr: 11
    doc: >-
      Runtime virtual addresses for the corresponding data sections.  A
      loader copies data_offsets[i]..data_offsets[i]+data_sizes[i] to this
      address.
  - id: text_sizes
    type: u4
    repeat: expr
    repeat-expr: 7
    doc: Byte lengths of the text sections.  Zero marks an unused table slot.
  - id: data_sizes
    type: u4
    repeat: expr
    repeat-expr: 11
    doc: Byte lengths of the data sections.  Zero marks an unused table slot.
  - id: bss_address
    type: u4
    doc: >-
      Runtime start address of the uninitialized-data (BSS) range.  BSS has
      no bytes in the DOL; the loader clears bss_size bytes at this address.
  - id: bss_size
    type: u4
    doc: Number of zero-initialized BSS bytes to allocate at bss_address.
  - id: entry_point
    type: u4
    doc: >-
      PowerPC virtual address at which control enters the executable after
      sections are loaded and BSS is initialized.  It should lie in a
      non-empty text section for a conventional executable.
  - id: padding
    size: 0x1c
    doc: >-
      Reserved header tail.  Together with the preceding tables and fields it
      makes the fixed DOL header exactly 0x100 bytes; preserve these bytes
      when rewriting a DOL.

instances:
  text_sections:
    pos: text_offsets[_index]
    size: text_sizes[_index]
    repeat: expr
    repeat-expr: 7
    doc: >-
      Raw bytes for each text-section table entry.  The entry remains an
      empty byte array for an unused zero-length slot.
  data_sections:
    pos: data_offsets[_index]
    size: data_sizes[_index]
    repeat: expr
    repeat-expr: 11
    doc: >-
      Raw bytes for each data-section table entry.  The section tables need
      not be physically ordered, so consumers should use their paired
      offset/size values rather than assume a sequential file layout.
