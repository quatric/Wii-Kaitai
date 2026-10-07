meta:
  id: dsi_export_bin
  title: DSiWare SD-card export (.bin), decrypted block layout
  file-extension: bin
  endian: be
doc: |
  The "DSiWare export" `.bin` that the DSi writes to an SD card (GBATEK
  "Tad Files"). On disk every part is an "ES block" -- data followed by a
  0x20-byte metablock (16-byte MAC + 16-byte info) -- encrypted with AES-CCM-like
  counters; this definition describes the *decrypted* block geometry, so it
  applies to data after twltool-style decryption. nintoolbox decrypts the
  fixed-key blocks, then derives the console-specific key from the TW
  certificate in the footer (a 16-hex-digit console ID) for the tmd and app.

  Layout (offset, data length):

      0x0000  0x4000  banner (icon/title; 0x23c0 bytes used, rest zero)  fixed key
      0x4020  0x00b4  header, ID "4ANT"                                  fixed key
      0x40f4  0x0440  footer: SHA-1s + certificates                      fixed key
      0x4554  ...     title.tmd, app (SRL), 7 unused slots, public.sav, banner.sav

  The header's eleven big-endian sizes at 0x28 give the length of each
  content slot (zero = absent, no ES block). Each present block is `size`
  data bytes plus 0x20 metabytes. Header `+0x20` (BE) and `+0x24` (LE) hold
  the title id low and high words. The footer carries a SHA-1 of the banner at
  0x00, the header at 0x14, then one per slot starting at 0x28 (stride 0x14),
  the AP certificate at 0x140 and the TW certificate at 0x2c0 (0x180 each).
seq:
  - id: banner_block
    type: es_block(0x4000)
  - id: header_block
    type: header_es_block
  - id: footer_block
    type: footer_es_block
  - id: slots
    type: slot_block(_index)
    repeat: expr
    repeat-expr: 11
types:
  es_block:
    params:
      - id: length
        type: u4
    seq:
      - id: data
        size: length
      - id: metablock
        type: metablock
  metablock:
    seq:
      - id: mac
        size: 16
      - id: info
        size: 16
        doc: Starts with the marker 0x3a and the big-endian block length in bytes 13..15.
  header_es_block:
    seq:
      - id: data
        size: 0xb4
        type: header
      - id: metablock
        type: metablock
  header:
    seq:
      - id: magic
        contents: '4ANT'
      - id: unknown_04
        size: 0x1c
      - id: title_id_low
        type: u4
        doc: Big-endian (game code).
      - id: title_id_high
        type: u4le
      - id: slot_sizes
        type: u4
        repeat: expr
        repeat-expr: 11
        doc: |
          Plain data length of each content slot, in file order: title.tmd,
          app (SRL), 7 unused, public.sav, banner.sav. Zero means the slot's ES
          block is absent.
      - id: rest
        size-eos: true
  footer_es_block:
    seq:
      - id: data
        size: 0x440
        type: footer
      - id: metablock
        type: metablock
  footer:
    seq:
      - id: banner_sha1
        size: 20
      - id: header_sha1
        size: 20
      - id: slot_sha1
        size: 20
        repeat: expr
        repeat-expr: 11
      - id: unknown_104
        size: 0x3c
      - id: ap_cert
        size: 0x180
      - id: tw_cert
        size: 0x180
        doc: |
          Contains `TW` plus the 16 hex digit console ID in its key name at
          cert offset 0xc4; that ID derives the key for the tmd and app blocks.
  slot_block:
    params:
      - id: index
        type: s4
    seq:
      - id: data
        size: length
        if: length != 0
      - id: metablock
        type: metablock
        if: length != 0
    instances:
      length:
        value: _root.header_block.data.slot_sizes[index]
