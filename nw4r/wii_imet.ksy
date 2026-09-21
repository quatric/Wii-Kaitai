meta:
  id: wii_imet
  endian: be
  title: Wii channel banner IMET header
doc: |
  Wii channel banner IMET header, per lib-wii-banner.h. Magic sits
  at a fixed offset from the start of this structure regardless of
  the leading padding scheme the caller stripped (0x40 for a disc
  /opening.bnr, 0 for the rare unpadded variant, 0x80 for a NAND
  content's 00000000.app); this definition starts right at the
  magic. The embedded U8 archive begins immediately after the fixed
  0x600-byte header.

  wiibrew.org's Opening.bnr page describes the same header (there
  documented starting from the leading padding rather than from `magic`)
  and adds two details worth carrying over cautiously, since this
  definition's field names and theirs do not line up one-to-one and the
  mapping was not independently re-verified against samples: the trailing
  MD5 documented there is said to cover only the header itself (offset 0
  through the hash-size field, with the hash field zeroed for the
  calculation) rather than the U8 payload that follows it, and the region
  between the title array and that checksum is described as further
  fixed-purpose fields (content indexes, a flags byte) rather than
  entirely unused padding -- consistent with `unknown_after_titles` here
  not actually being free-form.
doc-ref: 'http://wiibrew.org/wiki/Opening.bnr'
seq:
  - id: magic
    contents: "IMET"
  - id: unknown_04
    size: 0xc
    doc: |
      Unidentified 12 bytes between `magic` and `header_size`. wiibrew's
      description of this same header places a hash-size field and a
      version field (observed as 3) somewhere in this neighbourhood, but
      the exact split was not confirmed here, so the bytes are left
      opaque rather than guessed at.
  - id: header_size
    type: u4
    doc: Normally IMET_SIZE (0x600).
  - id: icon_size
    type: u4
    doc: Decompressed size in bytes of the icon.bin U8 entry that follows this header.
  - id: banner_size
    type: u4
    doc: Decompressed size in bytes of the banner.bin U8 entry.
  - id: sound_size
    type: u4
    doc: Decompressed size in bytes of the sound.bin U8 entry, 0 for a silent channel banner.
  - id: unknown_28
    size: 4
  - id: titles
    type: str
    size: 0x54
    encoding: UTF-16BE
    repeat: expr
    repeat-expr: 10
    doc: |
      Wii menu language order (not the SMDH or NDS banner order): Japanese,
      English, German, French, Spanish, Italian, Dutch, (reserved slot,
      unused pre-Korean-support region), simplified Chinese/reserved,
      Korean, per wiibrew's language table for this same array. Each
      0x54-byte (42 UTF-16 code unit) slot is NUL-padded, not
      NUL-terminated only, so trailing bytes past the title text are zero
      rather than garbage in every sample seen.
  - id: unknown_after_titles
    size-eos: true
    doc: |
      Covers the region wiibrew describes as further content-index and
      flag fields plus fixed padding, and finally the header's own MD5 --
      none of which is broken out here since the exact offsets were not
      independently verified. Do not assume this tail is safe to zero or
      ignore when re-packing a banner: per wiibrew, the Wii Menu checks
      the MD5 that lives somewhere in this range and can refuse a banner
      whose checksum does not match its own header bytes.
