meta:
  id: nus3audio
  file-extension: nus3audio
  endian: le
  title: Bandai Namco NUS3AUDIO audio stream archive
doc: |
  Bundles per-track audio streams for Namco's NUS3 middleware, most
  notably Super Smash Bros. Ultimate. A small chunk-tag container: each
  chunk is an 8-byte tag (4 ASCII characters, NUL-padded) followed by a
  u4 payload size and that many payload bytes.

  Track payloads are whole audio files (IDSP or Opus in practice) packed
  back to back in the `pack` chunk; `adof` gives each track's offset and
  size into it, `nmof` gives each track's name offset into `tnnm`.

  Reference: nintoolbox project/src/lib-nus3audio.c
  (ExtractNUS3AudioArchive / CreateNUS3AudioArchive).
seq:
  - id: magic
    contents: "NUS3"
  - id: len_body
    type: u4
    doc: Size of all chunks that follow, i.e. file size minus this 8-byte header.
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 8
        encoding: ASCII
        pad-right: 0
      - id: len_payload
        type: u4
      - id: payload
        size: len_payload
        type:
          switch-on: tag.substring(0, 4)
          cases:
            '"AUDI"': audiindx_body
            '"TNID"': tnid_body
            '"NMOF"': offset_table
            '"ADOF"': adof_body
            '"TNNM"': tnnm_body
            _: raw_body

  raw_body:
    seq:
      - id: data
        size-eos: true

  audiindx_body:
    doc: "AUDIINDX chunk: number of tracks in the archive."
    seq:
      - id: n_tracks
        type: u4

  tnid_body:
    doc: "TNID chunk: one arbitrary track id per track."
    seq:
      - id: track_id
        type: u4
        repeat: eos

  offset_table:
    doc: "NMOF chunk: one offset into TNNM per track (0 if unnamed)."
    seq:
      - id: name_offset
        type: u4
        repeat: eos

  adof_body:
    doc: "ADOF chunk: one (offset, size) pair into PACK per track."
    seq:
      - id: entry
        type: adof_entry
        repeat: eos

  adof_entry:
    seq:
      - id: ofs_data
        type: u4
        doc: Offset of this track's payload, relative to the start of PACK's payload.
      - id: len_data
        type: u4

  tnnm_body:
    doc: |
      TNNM chunk: back-to-back Pascal-style strings, one per named track
      (unnamed tracks have no entry and are keyed by index instead).
    seq:
      - id: entry
        type: tnnm_entry
        repeat: eos

  tnnm_entry:
    seq:
      - id: len_name
        type: u1
      - id: name
        type: str
        size: len_name
        encoding: ASCII
        doc: Track name, including its terminating NUL in `len_name`.
