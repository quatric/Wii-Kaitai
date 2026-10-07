meta:
  id: nibm
  title: NIBM streamed audio wrapper (CSI Hard Evidence .aud)
  file-extension: aud
  endian: le
doc: |
  "NIBM" streamed-audio wrapper from CSI: Hard Evidence (Wii). The file is a
  serialized class instance: magic, version, count, length-prefixed type
  names (`class AudioData`, `struct AudioData::Streamed`), a few `u4` fields
  (sample rates of 44100 and 22050 appear) and finally the audio payload,
  which in all 311 retail samples is a complete Ogg Vorbis stream starting at
  offset 126 and ending exactly at EOF.

  The field list between `count` and the Ogg stream is not modelled; this
  definition exposes the wrapper and the Ogg payload, found the way
  nintoolbox finds it (the first `OggS` page).
seq:
  - id: magic
    contents: 'NIBM'
  - id: version
    type: u4
    doc: Always 2.
  - id: count
    type: u4
  - id: body
    size-eos: true
    doc: |
      Serialized class header (type names and fields) followed by the Ogg
      Vorbis stream. In every retail file the stream begins at file offset
      126, so `ogg_stream` is valid for the common case; for others locate the
      first `OggS` page.
instances:
  ogg_stream:
    pos: 126
    size-eos: true
    doc: Ogg Vorbis stream (starts with `OggS`).
