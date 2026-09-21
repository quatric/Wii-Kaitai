meta:
  id: rwav
  file-extension:
    - rwav
    - brwav
  endian: be
  title: NW4R RWAV wave sample
doc: |
  A single audio sample in NintendoWare for Revolution's wave container --
  one waveform, not a stream. RWAR wave archives hold these back to back,
  and an RBNK instrument bank's `InstParam` selects one by index, so a
  `.brwav` on disk is normally something that was pulled out of an RWAR
  rather than something a game shipped loose.

  RWAV is the Wii member of a family that keeps the same idea across three
  console generations but not the same layout: the Wii U / Switch FWAV and
  the 3DS CWAV in `nw4c/bxwav.ksy` replace this file's fixed header and bare
  offset table with NW4C's typed `SizedReference` blocks. Only the sample
  data itself -- DSP-ADPCM, planar PCM16 or planar PCM8, one block per
  channel -- carries over unchanged.

  DSP-ADPCM samples here use the same 16-coefficient predictor and
  history-preload scheme as the standalone `.dsp` file
  (`nw4r/dsp.ksy`) and BRSTM's channel coefficient blocks
  (`nw4r/brstm.ksy`); `adpcm_info` below is effectively that same 46-byte
  SDK structure embedded rather than standalone. Unlike a `.dsp` file,
  however, an RWAV never carries raw frame bytes as its *only* content --
  `is_loop`/`loop_start`/`loop_end` and the channel/data-block indirection
  exist because this format is meant to be pulled out of an RWAR archive
  and played by an NW4R sound engine, not decoded standalone.

  The byte order is whatever `bom` says. Every real file seen is big-endian,
  and this definition is declared `be` for that reason; a little-endian RWAV
  is legal by the header's own rules but has not been observed.

  Validated against four real RWAVs extracted from `rv_forest.brsar` (Wii
  Animal Crossing: City Folk), all version 0x0102 22 kHz mono DSP-ADPCM, and
  against big-endian and little-endian files in all three encodings written
  by mobipeg's `rwav` muxer.
seq:
  - id: magic
    contents: 'RWAV'
  - id: bom
    type: u2
    doc: |
      0xFEFF in a big-endian file, 0xFFFE in a little-endian one. This is the
      only thing that decides the byte order of every field below -- the
      magic does not, and a reader that assumes big-endian from the magic
      alone will silently misread a little-endian file rather than fail.
  - id: version
    type: u2
    doc: |
      0x0102 in the retail Animal Crossing: City Folk samples. mobipeg writes
      0x0100. Nothing in the layout below is known to differ between the two.
  - id: len_file
    type: u4
    doc: Total size of the RWAV, header included.
  - id: len_header
    type: u2
    doc: 0x20 in every observed file -- the offset at which `info` begins.
  - id: num_chunks
    type: u2
    doc: 2 in every observed file, INFO and DATA.
  - id: ofs_info
    type: u4
  - id: len_info
    type: u4
  - id: ofs_data
    type: u4
  - id: len_data
    type: u4
instances:
  info:
    pos: ofs_info
    type: info_chunk
  data:
    pos: ofs_data
    size: len_data
    type: data_chunk
types:
  data_chunk:
    doc: |
      The sample blocks. Channels are stored one after another, not
      interleaved, and each channel's `ChannelInfo.ofs_channel_data` is
      relative to `payload` -- that is, to `ofs_data + 8`, past this
      chunk's own magic and length.
    seq:
      - id: magic
        contents: 'DATA'
      - id: len_chunk
        type: u4
      - id: payload
        size-eos: true
  info_chunk:
    seq:
      - id: magic
        contents: 'INFO'
      - id: len_chunk
        type: u4
      - id: wave
        size: len_chunk - 8
        type: wave_info
        doc: |
          Given its own substream, because every offset inside `wave_info`
          is relative to `wave_info`'s own start rather than to the file.
  wave_info:
    doc: |
      NW4R `WaveInfo`. Every offset inside it, and inside the structures it
      points at, is relative to the start of this structure.
    seq:
      - id: encoding
        type: u1
        enum: encoding
      - id: is_loop
        type: u1
      - id: num_channels
        type: u1
      - id: sample_rate_high
        type: u1
        doc: |
          High byte of a 24-bit sample rate, `sample_rate_high << 16 |
          sample_rate_low`. Zero in every observed file, since no rate in
          use here reaches 65536 Hz.
      - id: sample_rate_low
        type: u2
      - id: reserved
        type: u2
      - id: loop_start
        type: u4
        doc: |
          Loop start. Counted in ADPCM nibbles when `encoding` is
          `dsp_adpcm`, and in samples otherwise -- the same unit as
          `loop_end`. Meaningful only when `is_loop` is set.
      - id: loop_end
        type: u4
        doc: |
          One past the last sample, in the same unit as `loop_start`, and so
          also the length of the waveform: a non-looping file still fills
          this in, and it is where the sample count comes from.
      - id: ofs_channel_table
        type: u4
        doc: |
          Offset to `channel_table`, from the start of `wave_info`. 0x1C in
          every observed file, which puts the table immediately after this
          structure.
      - id: data_location
        type: u4
        doc: |
          Absolute offset of the sample data. Zero in files written by
          mobipeg and 0x78 in the retail samples; readers take the location
          from `ofs_data` and each channel's own offset instead, so a wrong
          value here goes unnoticed.
      - id: reserved2
        type: u4
    instances:
      sample_rate:
        value: (sample_rate_high << 16) | sample_rate_low
      channel_table:
        pos: ofs_channel_table
        type: channel_ref
        repeat: expr
        repeat-expr: num_channels
        doc: |
          One offset per channel, each relative to the start of
          `wave_info`, pointing at that channel's `channel_info`. Bare
          offsets -- unlike NW4C's reference tables there is no count here,
          so `num_channels` is the only thing that bounds it.
  channel_ref:
    seq:
      - id: ofs_channel_info
        type: u4
    instances:
      channel_info:
        pos: ofs_channel_info
        type: channel_info
  channel_info:
    doc: |
      NW4R `ChannelInfo`, 28 bytes. One per channel.
    seq:
      - id: ofs_channel_data
        type: u4
        doc: |
          Where this channel's block starts, relative to the DATA chunk's
          `payload`.
      - id: ofs_adpcm_info
        type: u4
        doc: |
          Offset to this channel's `adpcm_info`, relative to the start of
          `wave_info` -- not to this structure. Only meaningful when
          `encoding` is `dsp_adpcm`.
      - id: volume_front_left
        type: u4
      - id: volume_front_right
        type: u4
      - id: volume_rear_left
        type: u4
      - id: volume_rear_right
        type: u4
        doc: |
          8.24 fixed point, so 0x01000000 is unity. All four are 0x01000000
          throughout the retail set. mobipeg's `rwav` muxer writes a bare
          1 in each instead, which is unity misread as an integer -- it
          costs nothing here, since nothing in the decode path reads these,
          but a file written that way is not what a game would ship.
      - id: reserved
        type: u4
    instances:
      adpcm_info:
        pos: ofs_adpcm_info
        type: adpcm_info
        if: ofs_adpcm_info != 0
  adpcm_info:
    doc: |
      The DSP-ADPCM parameter block, the same 46-byte structure the GameCube
      SDK's `.dsp` files and BRSTM carry: sixteen predictor coefficients
      followed by the initial and loop decoder state.

      A decoder needs only the coefficients to start at sample zero; the
      loop triplet is what lets it jump to `loop_start` without decoding the
      run-up.
    seq:
      - id: coef
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: gain
        type: u2
        doc: Zero in every observed file.
      - id: pred_scale
        type: u2
      - id: yn1
        type: s2
      - id: yn2
        type: s2
        doc: Decoder state for the first frame. All three are zero in the
          retail samples, as they must be for a stream that starts at
          silence.
      - id: loop_pred_scale
        type: u2
      - id: loop_yn1
        type: s2
      - id: loop_yn2
        type: s2
        doc: Decoder state to restore when jumping back to `loop_start`.
enums:
  encoding:
    0:
      id: pcm8
      doc: 8-bit signed PCM, one byte per sample, planar across channels.
    1:
      id: pcm16
      doc: 16-bit signed big-endian PCM (matching `bom`), planar across channels.
    2:
      id: dsp_adpcm
      doc: Nintendo DSP-ADPCM, 8:1 compressed relative to 16-bit PCM; see `nw4r/dsp.ksy` for the codec's bit layout.
