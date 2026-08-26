meta:
  id: wad
  file-extension: wad
  endian: be
  title: Wii installable title (WAD)
doc: |
  An installable Wii title: a certificate chain, an optional certificate
  revocation list, a ticket, a TMD (title metadata) and the title's own
  contents, concatenated in that order. Every section starts on its own
  64-byte boundary -- including the header itself, which is a fixed
  0x20 bytes but still leaves a 0x20-byte gap before `certificates`
  begins.

  The contents are AES-128-CBC encrypted with the title key, which the
  ticket carries encrypted with one of the console's common keys -- the
  same two-step scheme a Wii disc's own partitions use, which is why
  `wiimms-iso-tools-plus`'s `x-wad.c` reuses its disc-crypto helpers
  rather than a separate implementation. Decryption itself is out of
  scope for this definition (as it is for every other container in this
  batch): `title_key_encrypted` and each content's `encrypted_data` are
  exposed as opaque bytes, not decrypted here.

  Only the TMD's content hash can confirm the title key was right --
  `wiimms-iso-tools-plus`'s own extractor decrypts unconditionally and
  only checks the SHA-1 hash afterward, warning rather than refusing when
  it disagrees, because a wrong common key is not the only thing that
  makes a hash mismatch.

  A content's *stored* size is not its real size: `wd_tmd_content_t.size`
  (`len_content` here) is the plaintext length, but only whole AES blocks
  are written, so what actually occupies the file is `len_content`
  rounded up to 16 bytes -- and that value is rounded up *again*, to the
  64-byte section grid every other region uses, for where the *next*
  content begins. Both roundings are confirmed below against a real
  file's declared sizes.

  ## Validated against

  Two real WAD files, `DiskCheck v1.00` (2 contents) and `Photo Channel
  v1.1 (World) (v3)`. Every section size and offset, and every content's
  encrypted size, were checked against `wiimms-iso-tools-plus`'s own `wit
  XINFO` output for both -- including that this definition's content
  walk (using the two roundings above) lands on exactly the same content
  count and matching per-content sizes that `wit` reports.
seq:
  - id: len_header
    type: u4
    doc: Always 0x20.
  - id: wad_type
    type: u4
    enum: wad_type
  - id: len_certificates
    type: u4
  - id: len_crl
    type: u4
    doc: Certificate revocation list. 0 in every file checked.
  - id: len_ticket
    type: u4
  - id: len_tmd
    type: u4
  - id: len_data
    type: u4
    doc: Every content's encrypted bytes together, each already 64-byte padded.
  - id: len_footer
    type: u4
instances:
  ofs_certificates:
    value: (len_header + 0x3f) / 0x40 * 0x40
    doc: |
      The header is fixed at 0x20 bytes but the next section still starts
      on the 64-byte grid, so this is 0x40, not 0x20.
  ofs_crl:
    value: ofs_certificates + (len_certificates + 0x3f) / 0x40 * 0x40
  ofs_ticket:
    value: ofs_crl + (len_crl + 0x3f) / 0x40 * 0x40
  ofs_tmd:
    value: ofs_ticket + (len_ticket + 0x3f) / 0x40 * 0x40
  ofs_data:
    value: ofs_tmd + (len_tmd + 0x3f) / 0x40 * 0x40
  ofs_footer:
    value: ofs_data + (len_data + 0x3f) / 0x40 * 0x40
  certificates:
    pos: ofs_certificates
    size: len_certificates
  ticket:
    pos: ofs_ticket
    size: len_ticket
    type: ticket
    if: len_ticket > 0
  tmd:
    pos: ofs_tmd
    size: len_tmd
    type: tmd
    if: len_tmd > 0
  footer:
    pos: ofs_footer
    size: len_footer
    if: len_footer > 0
  contents:
    pos: ofs_data
    type: wad_content(_index)
    repeat: expr
    repeat-expr: tmd.num_contents
    if: len_tmd > 0
    doc: |
      One per `tmd.contents` entry, in the same order, read back to back
      -- each one's own stored (post-16-byte-rounding) size, further
      padded up to the 64-byte grid, is what tells this array where the
      next entry starts. Not addressable by `content_id`; look that up in
      `tmd.contents` first if that is what you have.
types:
  wad_content:
    params:
      - id: index
        type: u4
    seq:
      - id: encrypted_data
        size: _root.tmd.contents[index].len_content_stored
        doc: |
          AES-128-CBC encrypted, `_root.tmd.contents[index].len_content`
          bytes once decrypted (which this definition does not do) --
          rounded up to a whole number of 16-byte AES blocks here.
      - id: padding
        size: (64 - (_root.tmd.contents[index].len_content_stored % 64)) % 64
  ticket:
    doc: |
      Fixed 0x2A4-byte layout; see WiiBrew's Ticket page, which
      `wiimms-iso-tools-plus`'s own struct comment cites directly. Fields
      this definition doesn't need for container-level parsing (the
      signature, most of the padding) are collapsed into `reserved*`
      rather than named individually.
    seq:
      - id: sig_type
        type: u4
      - id: signature
        size: 0x100
      - id: reserved1
        size: 0x3c
      - id: issuer
        size: 0x40
      - id: reserved2
        size: 0x3f
      - id: title_key_encrypted
        size: 0x10
        doc: |
          AES-128-CBC encrypted with one of the console's common keys
          (selected by `common_key_index`), IV = `title_id` zero-padded
          to 16 bytes. Decryption is out of scope here.
      - id: reserved3
        size: 1
      - id: ticket_id
        size: 8
      - id: console_id
        size: 4
      - id: title_id
        size: 8
      - id: reserved4
        size: 2
      - id: num_dlc
        type: u2
      - id: reserved5
        size: 9
      - id: common_key_index
        type: u1
        doc: 0 selects the normal common key, 1 the Korean one.
      - id: reserved6
        size: 0x62
  tmd:
    doc: |
      Fixed-size header followed by `num_contents` `tmd_content` records.
      See WiiBrew's Title metadata page, cited the same way in
      `wiimms-iso-tools-plus`'s own struct comment.
    seq:
      - id: sig_type
        type: u4
      - id: signature
        size: 0x100
      - id: reserved1
        size: 0x3c
      - id: issuer
        size: 0x40
      - id: version
        type: u1
      - id: ca_crl_version
        type: u1
      - id: signer_crl_version
        type: u1
      - id: reserved2
        size: 1
      - id: system_version
        type: u8
        doc: The IOS version this title needs.
      - id: title_id
        size: 8
      - id: title_type
        type: u4
      - id: group_id
        type: u2
      - id: reserved3
        size: 0x3e
      - id: access_rights
        type: u4
      - id: title_version
        type: u2
      - id: num_contents
        type: u2
      - id: boot_index
        type: u2
      - id: reserved4
        size: 2
      - id: contents
        type: tmd_content
        repeat: expr
        repeat-expr: num_contents
  tmd_content:
    seq:
      - id: content_id
        type: u4
      - id: index
        type: u2
        doc: |
          Also the top two bytes of this content's AES-CBC IV when
          decrypting (the bottom 14 bytes are zero) -- confirmed against
          `x-wad.c`'s own `content_iv()`, not independently re-derived
          here.
      - id: content_type
        type: u2
      - id: len_content
        type: u8
        doc: The real, plaintext content size -- see `len_content_stored`.
      - id: hash
        size: 20
        doc: |
          SHA-1 over the decrypted content. The only thing that can
          confirm the title key was right; not checked by this
          definition, which does not decrypt.
    instances:
      len_content_stored:
        value: (len_content + 15) / 16 * 16
        doc: |
          Only whole AES blocks are written, so this is what actually
          occupies the file -- `len_content` itself is not a multiple of
          16 in general.
enums:
  wad_type:
    0x49730000: normal_title
    0x69620000: boot2_image
