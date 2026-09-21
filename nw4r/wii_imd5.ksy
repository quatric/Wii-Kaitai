meta:
  id: wii_imd5
  endian: be
  title: Wii menu resource IMD5 header
doc: |
  The 0x20-byte header Nintendo puts in front of banner.bin,
  icon.bin and sound.bin (and other Wii menu resources), per
  lib-wii-banner.h. The payload may itself be an "LZ77"-wrapped
  LZ10/LZ11 stream (not modeled here).

  This is a plain integrity wrapper, not a container format: it has no
  section list and no type tag for the payload beyond the file it is
  attached to. wiibrew.org's Opening.bnr page describes the same layout
  for banner.bin/icon.bin/sound.bin as extracted from an IMET-headed
  opening.bnr's inner U8 archive -- `magic`, a size, 8 reserved bytes and
  an MD5 -- and notes that without a correct IMD5 wrapper the Wii Menu
  shows a black screen for the channel rather than an error, since the
  system relies on this header (not just the U8 archive itself) to
  accept the resource.
doc-ref: 'http://wiibrew.org/wiki/Opening.bnr'
seq:
  - id: magic
    contents: "IMD5"
  - id: payload_size
    type: u4
    doc: |
      Size of `payload` in bytes -- the length of the file *after* this
      0x20-byte header, not the whole file's length.
  - id: reserved
    size: 8
    doc: Zero in every sample seen; wiibrew documents no meaning for these bytes.
  - id: md5
    size: 16
    doc: |
      MD5 of `payload` alone (the header itself, crypto field included, is
      not part of the hash). The Wii Menu is reported to refuse to open a
      channel banner whose payload does not match this checksum, which is
      why re-packed banner.bin/icon.bin/sound.bin files need it
      recomputed rather than left stale.
  - id: payload
    size-eos: true
    doc: |
      Almost always an LZ77-compressed U8 (`.arc`) archive in practice --
      TPL textures for banner.bin/icon.bin, a BRSAR-less raw stream for
      sound.bin -- but this header does not itself say so; decompression
      and archive parsing are out of scope here.
