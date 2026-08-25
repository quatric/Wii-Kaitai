meta:
  id: bxwav
  file-extension:
    - bfwav
    - fwav
    - bcwav
    - cwav
  title: NW4C FWAV / CWAV wave sample
doc: |
  A single audio sample in NintendoWare for CTR/Cafe's wave container --
  FWAV on Wii U and Switch, CWAV on the 3DS. One waveform, not a stream.
  FWAR / CWAR wave archives hold these back to back, so a loose `.bfwav` or
  `.bcwav` is normally something that was pulled out of an archive rather
  than something a game shipped on its own.

  FWAV and CWAV are the same layout under two magics, which is why one
  definition covers both. They are the successor to the Wii's RWAV
  (`nw4r/rwav.ksy`) and keep its idea -- DSP-ADPCM, planar PCM16 or planar
  PCM8, one block per channel, never interleaved -- while replacing RWAV's
  fixed header and bare offset table with NW4C's typed references.

  ## Byte order is a field, not a convention

  FWAV files are normally big-endian and CWAV files little-endian, but
  nothing enforces that: `bom` decides, and this definition switches on it
  rather than on the magic. Getting this wrong is not a theoretical risk.
  Every real 3DS `.bcwav` was rejected by mobipeg's demuxer until
  2026-08-25, because it read each `sized_reference`'s type id together with
  its padding as one 32-bit word. Big-endian, `0x7000` followed by `0x0000`
  reads back as `0x70000000` and the check passes by luck; little-endian the
  same bytes give `0x00007000` and every file fails.

  The root type here carries no fields at all. It exists only so that
  `bom_probe` can be read before `file`, since a structure's endianness has
  to be settled before the structure itself is parsed.

  ## Validated against

  Three real CWAVs carved out of a retail 3DS BCSAR (44.1 kHz mono
  DSP-ADPCM, little-endian), three real FWAVs from a retail Wii U BFSAR
  (32 kHz mono and stereo DSP-ADPCM, big-endian), and files in every
  encoding written by mobipeg's `fwav` and `cwav` muxers.
instances:
  bom_probe:
    pos: 4
    type: u2be
    doc: |
      The byte-order mark, read positionally and big-endian because the
      answer cannot depend on the question. Everything in `file` switches
      on it.
  file:
    pos: 0
    type: wave_file
types:
  wave_file:
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
        doc: '`FWAV` on Wii U and Switch, `CWAV` on the 3DS.'
      - id: bom
        type: u2be
        doc: 0xFEFF big-endian, 0xFFFE little-endian. Same bytes as `bom_probe`.
      - id: len_header
        type: u2
        doc: 0x40 in every observed file -- where the first block begins.
      - id: version
        type: u4
        doc: |
          0x00010100 in the retail FWAVs and in everything mobipeg writes.
          The retail CWAVs carry the bytes `00 01 01 02`, which the file's
          own little-endian order turns into 0x02010100 -- the field looks
          to be a packed quadruple of version bytes that is not meant to be
          byte-swapped, so compare it as bytes rather than as a number.
      - id: len_file
        type: u4
      - id: num_blocks
        type: u2
      - id: reserved
        type: u2
      - id: blocks
        type: sized_reference
        repeat: expr
        repeat-expr: num_blocks
        doc: |
          Two entries in every observed file: INFO (0x7000) then DATA
          (0x7001).
    instances:
      info_ref:
        value: 'blocks[0].type_id == block_type::info ? blocks[0] : blocks[1]'
      data_ref:
        value: 'blocks[0].type_id == block_type::data ? blocks[0] : blocks[1]'
      info:
        pos: info_ref.ofs
        type: info_block
        if: info_ref.ofs != 0
      data:
        pos: data_ref.ofs
        size: data_ref.len_block
        type: data_block
        if: data_ref.ofs != 0
  sized_reference:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      NW4C `SizedReference`: a 16-bit type id, 16 bits of padding, then a
      32-bit offset and a 32-bit size. The padding is what makes the id look
      like the high half of a 32-bit word in a big-endian file. It is not,
      and reading it that way breaks on every little-endian file.
    seq:
      - id: type_id
        type: u2
        enum: block_type
      - id: padding
        type: u2
      - id: ofs
        type: u4
      - id: len_block
        type: u4
  reference:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      NW4C `Reference`: the same thing without the size, used inside the
      INFO block where the target's length is implied by its type.
    seq:
      - id: type_id
        type: u2
        enum: ref_type
      - id: padding
        type: u2
      - id: ofs
        type: u4
    instances:
      channel_info:
        pos: ofs
        type: channel_info
        if: type_id == ref_type::channel_info
        doc: |
          Only meaningful for the `channel_info` (0x7100) entries of a
          `channel_ref_table`, whose `ofs` is relative to that table -- the
          same stream this reference was read from.
      dsp_info:
        pos: ofs + channel_info.adpcm_info.ofs
        type: dsp_adpcm_info
        if: >-
          type_id == ref_type::channel_info
          and channel_info.adpcm_info.ofs != 0xffffffff
          and channel_info.adpcm_info.type_id == ref_type::dsp_adpcm_info
        doc: |
          The channel's coefficient block. Resolved from here rather than
          from inside `channel_info`, because `adpcm_info.ofs` is relative
          to the start of that `channel_info` -- which is this reference's
          own `ofs`, and is not otherwise recoverable once parsing has
          moved inside it.
  data_block:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      The sample blocks. `payload` opens with 24 bytes of zero padding in
      every observed file, and each channel's `sample_data.ofs` is relative
      to `payload` and already counts that padding -- channel zero stores
      0x18, not 0. A reader that adds the padding a second time starts every
      channel three ADPCM frames late; mobipeg did exactly that until
      2026-08-25, at a cost of about 86 dB of round-trip SDR.
    seq:
      - id: magic
        contents: 'DATA'
      - id: len_block
        type: u4
      - id: payload
        size-eos: true
  info_block:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: magic
        contents: 'INFO'
      - id: len_block
        type: u4
      - id: wave
        size: len_block - 8
        type: wave_info
        doc: |
          Given its own substream, because every offset inside the INFO
          block is relative to something within it rather than to the file.
  wave_info:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    seq:
      - id: encoding
        type: u1
        enum: encoding
      - id: is_loop
        type: u1
      - id: padding
        type: u2
      - id: sample_rate
        type: u4
        doc: A full 32-bit field here, unlike RWAV's split 8+16-bit one.
      - id: loop_start
        type: u4
        doc: |
          In samples, not in ADPCM nibbles -- the other difference from
          RWAV, whose equivalent fields count nibbles for an ADPCM file.
          Meaningful only when `is_loop` is set.
      - id: loop_end
        type: u4
        doc: |
          One past the last sample, and so also the length of the waveform:
          a non-looping file still fills this in, and it is where the sample
          count comes from.
      - id: original_loop_start
        type: u4
        doc: |
          Zero throughout the FWAV set and in everything mobipeg writes. The
          retail CWAVs put a non-zero value here that tracks `loop_start`
          without matching it -- 0x5301 against a `loop_start` of 0x5400 in
          one sample -- consistent with a loop point carried over from the
          source material before resampling. Nothing reads it.
      - id: channel_refs
        size-eos: true
        type: channel_ref_table
        doc: |
          Given its own substream running to the end of the INFO block,
          because the table's entry offsets are relative to the table
          itself -- to its count field -- and not to `wave_info`.
  channel_ref_table:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      NW4C reference table: a count followed by that many `reference`s. Each
      entry's `ofs` is relative to the start of this table -- to the count,
      not to the first entry.
    seq:
      - id: num_channels
        type: u4
      - id: refs
        type: reference
        repeat: expr
        repeat-expr: num_channels
  channel_info:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      One per channel. Both references inside it are relative to the start
      of this structure, except `sample_data.ofs`, which is relative to the
      DATA block's `payload`.
    seq:
      - id: sample_data
        type: reference
        doc: |
          `type_id` is `sample_data` (0x1F00); `ofs` locates this channel's
          block inside the DATA block's `payload`.
      - id: adpcm_info
        type: reference
        doc: |
          `type_id` is `dsp_adpcm_info` (0x0300) for a DSP-ADPCM file. An
          `ofs` of 0xFFFFFFFF means there is none, which is what a PCM file
          carries.
      - id: reserved
        type: u4
  dsp_adpcm_info:
    meta:
      endian:
        switch-on: _root.bom_probe
        cases:
          0xfffe: le
          0xfeff: be
    doc: |
      Sixteen predictor coefficients and the decoder state, 44 bytes. Note
      the difference from RWAV's 46-byte block, which opens the state with a
      `gain` field that this one does not have.

      The coefficients are stored in the file's own byte order, which is
      what a decoder has to be told: FFmpeg's `adpcm_thp` expects them
      big-endian and `adpcm_thp_le` little-endian, and they are otherwise
      the same codec.
    seq:
      - id: coef
        type: s2
        repeat: expr
        repeat-expr: 16
      - id: pred_scale
        type: u2
      - id: yn1
        type: s2
      - id: yn2
        type: s2
        doc: |
          Decoder state for the first frame. All three are zero throughout
          the retail set, as they must be for a waveform starting at
          silence.
      - id: loop_pred_scale
        type: u2
      - id: loop_yn1
        type: s2
      - id: loop_yn2
        type: s2
        doc: |
          Decoder state to restore when jumping back to `loop_start`. These
          are the only non-zero state values in the retail samples, and only
          in the ones whose `is_loop` is set.
enums:
  encoding:
    0: pcm8
    1: pcm16
    2: dsp_adpcm
    3: ima_adpcm
  block_type:
    0x7000: info
    0x7001: data
  ref_type:
    0x0300: dsp_adpcm_info
    0x0301: ima_adpcm_info
    0x1f00: sample_data
    0x7100: channel_info
