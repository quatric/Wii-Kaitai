meta:
  id: brstm
  file-extension:
    - brstm
    - bfstm
    - bcstm
  title: NW4R/NW4C sound stream (BRSTM/BFSTM/BCSTM)
doc: |
  A streamed audio track -- background music, not a one-shot sample.
  DSP-ADPCM, planar PCM16 or planar PCM8, split into fixed-size interleaved
  blocks so a player can start from anywhere without decoding the whole
  file, unlike RWAV/FWAV/CWAV (`nw4r/rwav.ksy`, `nw4c/bxwav.ksy`) which hold
  one undivided sample.

  Two container generations share this one definition, and they are not
  the same shape:

  * **RSTM** (Wii, `.brstm`) -- a fixed header (magic, BOM, version, file
    size, header size, chunk count) followed by a small table of
    `(offset, size)` pairs pointing at HEAD and, in every sample seen,
    ADPC. DATA is not in that table at all -- its position comes from a
    field buried inside HEAD's own stream-info block.
  * **FSTM/CSTM** (Wii U/Switch and 3DS, `.bfstm`/`.bcstm`) -- a variable
    table of typed sections (INFO, SEEK, DATA), each carrying its own
    offset and size up front, so DATA's position is known immediately.

  Both put a HEAD/INFO chunk in the same shape underneath: a fixed
  3-reference table (stream info, an unread second reference, and a
  channel-info reference), each reference `marker(u4)=0x01000000,
  offset(u4)` relative to that chunk's own start. The stream-info block
  itself lives 8 bytes past its reference's offset -- every real file and
  every one mobipeg writes has those 8 bytes as an unread, unidentified
  prefix, consistent with the block having its own tag+length header that
  nothing here validates.

  The channel-info side is where the two generations really diverge, and
  each hides a second indirection behind one word ("V") read at
  `channel_info_ref.ofs + 16`:

  * RSTM: `V + 16` gives a table position, from which `channels + 1`
    entries of `(marker(u4), offset(u4))` are read backwards -- walking
    back `8*(channels+1)` bytes from that position. Only the first
    `channels` entries are ever used; the `+1`th is real, present in every
    sample checked, and never touched. Each channel's 32-byte coefficient
    block sits at the chunk's start `+ 16 + entries[ch].offset`.
  * FSTM/CSTM: no second table -- `channel_info_ref.ofs + 16 + V +
    channels*8 - 8` is itself the position of the first channel's
    coefficient block, arithmetic rather than indirection. Channels are
    packed `32 bytes of coefficients + 14 bytes of trailer` each.

  The DATA chunk itself opens with 24 bytes of zero padding before the
  first channel's samples -- the same convention as `nw4c/bxwav.ksy`'s
  `data_block`, confirmed here byte for byte against a real file (tag,
  length, 24 zero bytes, then real ADPCM nibbles at exactly
  `data_offset + 8 + 24`).

  ## Validated against

  Three real BRSTMs (a Wii U TVii Wii Menu jingle and two Mario Power
  Tennis tracks: 22050/32000/44100 Hz stereo DSP-ADPCM) and one real BFSTM
  (a Nintendo TVii Wii U title-logo jingle, 44100 Hz stereo DSP-ADPCM),
  plus files written by mobipeg's `brstm`/`bfstm`/`bcstm` muxers in every
  encoding -- channel count, sample rate, loop flag, total samples, block
  layout and the first coefficient of every channel all cross-checked
  against a from-scratch Python re-implementation of mobipeg's own
  `libavformat/brstm.c`, and the counts against `ffprobe`.

  A file downloaded as `.bcstm` (`Nintendo_Week_...-ha.bcstm`) turned out
  on inspection to be an FSTM (Wii U) stream under a `.bcstm` name, and
  moreover one whose HEAD-style region doesn't match either layout this
  definition covers -- a reminder that a file extension found in the wild
  is a guess, not a guarantee. It was excluded from the validated set
  rather than forced to fit.
instances:
  magic:
    pos: 0
    size: 4
    type: str
    encoding: ASCII
  bom_probe:
    pos: 4
    type: u2be
  stream:
    pos: 0
    type:
      switch-on: magic
      cases:
        '"RSTM"': legacy_stream
        '"FSTM"': modern_stream
        '"CSTM"': modern_stream
types:
  reference_be:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      A fixed-marker reference used inside HEAD/INFO's own body: a 4-byte
      marker, observed as `0x01000000` in every real file and everything
      mobipeg writes, followed by a 4-byte offset relative to that chunk's
      own start. Unlike `nw4c/bxwav.ksy`'s `reference`, the marker here is
      never anything else, so it is not modelled as an enum.
    seq:
      - id: marker
        type: u4
      - id: ofs
        type: u4
    instances:
      coefficients:
        pos: _parent.base + 16 + ofs
        type: dsp_coefficients
        doc: |
          Only meaningful for an entry of `info_body`'s
          `legacy_channel_table`, whose `ofs` is relative to the owning
          HEAD chunk's start (`_parent.base`) plus a fixed 16.
  chunk_ref:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: A bare `(offset, size)` pair, no self-contained type tag.
    seq:
      - id: ofs
        type: u4
      - id: len_chunk
        type: u4
    instances:
      tag:
        pos: ofs
        size: 4
        type: str
        encoding: ASCII
        doc: |
          The referenced chunk's own magic, read on demand -- HEAD always;
          a second RSTM entry is ADPC in every sample seen.
  legacy_stream:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: magic
        contents: 'RSTM'
      - id: bom
        type: u2be
      - id: version
        type: u2
        doc: 0x0100 in every observed file.
      - id: len_file
        type: u4
      - id: len_header
        type: u2
        doc: 0x40 in every observed file.
      - id: num_chunks
        type: u2
        doc: 2 in every observed file -- HEAD and (when present) ADPC.
      - id: chunks
        type: chunk_ref
        repeat: expr
        repeat-expr: num_chunks
    instances:
      head:
        pos: chunks[0].ofs
        type: info_body(chunks[0].ofs)
        doc: |
          HEAD, at `chunks[0]`. Named `head` rather than `info` to match
          the chunk's own magic; the substructure underneath (`info_body`)
          is identical in shape to FSTM/CSTM's INFO.
  modern_stream:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: magic
        type: str
        size: 4
        encoding: ASCII
      - id: bom
        type: u2be
      - id: len_header
        type: u2
        doc: 0x40 in every observed file.
      - id: version
        type: u4
        doc: 0x00030000 in every observed file.
      - id: len_file
        type: u4
      - id: num_sections
        type: u2
      - id: reserved
        type: u2
      - id: sections
        type: section_ref
        repeat: expr
        repeat-expr: num_sections
        doc: |
          Typed, unlike RSTM's bare table: each entry names its own kind
          (INFO 0x4000, SEEK 0x4001, DATA 0x4002, REGN 0x4003) rather than
          being identified by tag lookup.
    instances:
      info_ref:
        value: >-
          sections[0].section_type == section_type::info ? sections[0]
          : (sections[1].section_type == section_type::info ? sections[1] : sections[2])
      info:
        pos: info_ref.ofs
        type: info_body(info_ref.ofs)
  section_ref:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: section_type
        type: u2
        enum: section_type
      - id: padding
        type: u2
      - id: ofs
        type: u4
      - id: len_section
        type: u4
  info_body:
    params:
      - id: base
        type: u4
        doc: Absolute file offset of this HEAD/INFO chunk's own start.
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      HEAD (RSTM) and INFO (FSTM/CSTM) share this body. `is_modern` decides
      which of the two channel-table layouts applies, and which width
      `stream_info.sample_rate` is read as -- both differ between the
      generations, as described in the top-level doc. Every offset that
      follows is relative to `base`, not to this instance's own start,
      because that is how the format itself defines them.
    seq:
      - id: magic
        size: 4
        type: str
        encoding: ASCII
        doc: '`HEAD` on RSTM, `INFO` on FSTM/CSTM.'
      - id: len_chunk
        type: u4
      - id: stream_info_ref
        type: reference_be
      - id: unused_ref
        type: reference_be
        doc: |
          Present and well-formed in every real file and everything
          mobipeg writes, but read by no known decoder -- a plausible
          candidate is per-track volume/pan (as BRSAR sequences carry),
          left unconfirmed rather than guessed at.
      - id: channel_info_ref
        type: reference_be
    instances:
      is_modern:
        value: magic == "INFO"
      stream_info:
        pos: base + stream_info_ref.ofs + 8
        type: stream_info(is_modern)
        doc: |
          The extra `+ 8` is not this reference's declared offset; it
          skips 8 bytes that every real file and every mobipeg-written one
          carries at `stream_info_ref.ofs`, consistent with (never
          confirmed as) a tag+length pair belonging to the stream-info
          block itself.
      channel_table_probe:
        pos: base + channel_info_ref.ofs + 16
        type: u4
        doc: |
          The single word ("V" in the top-level doc) both generations
          read before diverging on what it means.
      new_toffset:
        value: >-
          is_modern
          ? (channel_info_ref.ofs + 16 + channel_table_probe + stream_info.num_channels * 8 - 8)
          : (channel_table_probe + 16)
        doc: |
          RSTM: a fresh relative offset, replacing the one just used to
          find `channel_table_probe`. FSTM/CSTM: not a replacement at all,
          just the final arithmetic position -- see `modern_channels_start`.
      legacy_channel_table:
        pos: base + new_toffset - 8 * (stream_info.num_channels + 1)
        type: reference_be
        repeat: expr
        repeat-expr: stream_info.num_channels + 1
        if: not is_modern
        doc: |
          `channels + 1` entries. Only the first `num_channels` are ever
          read by a decoder; the extra slot is real, present, and unused
          in every sample checked.
      modern_channels_start:
        value: base + new_toffset
        if: is_modern
        doc: Absolute position of the first channel's 32-byte coefficient block.
      coefficients:
        pos: modern_channels_start
        type: modern_channel_block
        repeat: expr
        repeat-expr: stream_info.num_channels
        if: is_modern and stream_info.codec == codec::dsp_adpcm
        doc: |
          FSTM/CSTM only, and contiguous -- each channel is 32 bytes of
          coefficients plus a 14-byte trailer, with no indirection needed.
          RSTM has no equivalent array here: read
          `legacy_channel_table[ch].coefficients` for each channel instead,
          since its per-channel positions are not contiguous.
  stream_info:
    params:
      - id: is_modern
        type: bool
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: codec
        type: u1
        enum: codec
      - id: is_loop
        type: u1
      - id: num_channels
        type: u1
      - id: reserved
        type: u1
      - id: sample_rate
        type:
          switch-on: is_modern
          cases:
            true: u4
            false: u2
      - id: reserved2
        type: u2
        if: not is_modern
      - id: loop_start
        type: u4
        doc: In samples. Meaningful only when `is_loop` is set.
      - id: total_samples
        type: u4
      - id: data_start
        type: u4
        if: not is_modern
        doc: |
          RSTM only -- the absolute file offset of the first sample byte,
          already past DATA's tag+length and its 24-byte pad. FSTM/CSTM
          gets this from the DATA section entry instead, so the field
          isn't here on that side.
      - id: block_count
        type: u4
      - id: block_size
        type: u4
        doc: Bytes of one channel's audio per block. 8192 in every sample seen.
      - id: samples_per_block
        type: u4
      - id: last_block_used_bytes
        type: u4
      - id: last_block_samples
        type: u4
      - id: last_block_size
        type: u4
  modern_channel_block:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: coefficients
        type: dsp_coefficients
      - id: trailer
        size: 14
        doc: Unread by mobipeg's demuxer; every observed file is all zero.
  dsp_coefficients:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      Sixteen predictor coefficients, the same table `nw4r/rwav.ksy`'s
      `adpcm_info` and `nw4c/bxwav.ksy`'s `dsp_adpcm_info` carry, without
      the surrounding decoder-state fields those two keep -- a stream
      resumes mid-file from block boundaries via ADPC/SEEK, not from a
      single saved `yn1`/`yn2` pair, so there is nothing here to save.
    seq:
      - id: coef
        type: s2
        repeat: expr
        repeat-expr: 16
enums:
  codec:
    0: pcm8
    1: pcm16
    2: dsp_adpcm
  section_type:
    0x4000: info
    0x4001: seek
    0x4002: data
    0x4003: regn
