meta:
  id: fakt_fast
  title: FAKT Software FAST archive (Crazy Machines .fst)
  file-extension: fst
  endian: le
doc: |
  FAKT Software "FAST" archive (Crazy Machines). Header: `FAST`, little-endian
  version `0x30000`, object count and block size, a short index, then one zlib
  stream per object. Each object's inflated payload (see `object`) starts
  with a big-endian `u8` object id. Sound objects carry
  `{u4 channels, u4 rate, u4 bits, u4 format, u4 size, u4 size}` at +0x10 and the
  data at +0x28 (format 2 = PCM16LE, 3 = Ogg Vorbis). nintoolbox writes
  objects as `<id>.wav`, `<id>.ogg` or `<id>.bin`.

  The index between the header and the zlib streams is only partially
  understood; `index_and_streams` keeps it raw.
seq:
  - id: magic
    contents: 'FAST'
  - id: version
    type: u4
    doc: 0x30000.
  - id: count
    type: u4
  - id: block_size
    type: u4
  - id: index_and_streams
    size-eos: true
types:
  object:
    doc: Inflated object payload (apply to the output of one zlib stream).
    meta:
      endian: be
    seq:
      - id: object_id
        type: u8
      - id: unknown_08
        type: u8
      - id: sound
        type: sound_header
  sound_header:
    seq:
      - id: channels
        type: u4
      - id: sample_rate
        type: u4
      - id: bits
        type: u4
      - id: format
        type: u4
        enum: format
      - id: size
        type: u4
      - id: size_again
        type: u4
      - id: pcm_or_ogg
        size-eos: true
enums:
  format:
    2: pcm16le
    3: ogg_vorbis
