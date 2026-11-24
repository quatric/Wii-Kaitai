meta:
  id: redspark
  title: RedSpark audio (.rsd, after un-XOR)
  file-extension: rsd
  endian: be
doc: |
  MadWorld, Imabikisou. The header is XOR-"encrypted" with a rolling key
  ("RedSpark" after decryption): key0 = be32(buf) ^ "RedS"; the first word is
  xored with key0, then key = rotl(key, 11), and every following 32-bit word w
  is xored with key = rotl(key, 3) + key. The header runs from 0 to
  `data_offset`; the audio data (not encrypted) follows. This definition
  describes the DECRYPTED header (Kaitai cannot express the rolling key), so
  feed it the decrypted bytes; `data` is the raw ADPCM region.

  Stream (bank_flag == 0): header at 0x30 holds rate @+0xc, frames @+0x10,
  channels @+0x1e, cue flag @+0x1f; 8-byte channel configs follow at +0x24,
  then 0x10 bytes of cue points if the flag is set, then 0x2e bytes of DSP
  coefficients per channel. ADPCM is interleaved per 8-byte frame
  (frame f of channel c at f * 8 * channels + 8 * c).

  Bank (bank_flag != 0): sound count u16 @0x30+0xc, a table of u32 header
  offsets (absolute within the header) at 0x30+0x20; each sound header has size
  @+4, rate @+8, sample nibbles @+0xc, data offset @+0x10 (from data_offset),
  alt nibbles @+0x14, DSP coefficients @+0x28.
seq:
  - id: magic
    contents: RedSpark
  - id: unk8
    size: 16
  - id: data_offset
    type: u4
  - id: bank_flag
    type: u2
  - id: type
    type: u2
    doc: 0 = no audio.
  - id: data_size
    type: u4
  - id: unk24
    size: 12
  - id: stream
    type: stream_header
    if: bank_flag == 0
  - id: bank
    type: bank_header
    if: bank_flag != 0
instances:
  data:
    pos: data_offset
    size-eos: true
types:
  stream_header:
    seq:
      - id: unk0
        size: 12
      - id: rate
        type: u4
      - id: frames
        type: u4
      - id: unk14
        size: 10
      - id: channels
        type: u1
      - id: has_cues
        type: u1
      - id: unk20
        size: 4
      - id: channel_configs
        size: 8
        repeat: expr
        repeat-expr: channels
      - id: cue_points
        size: 16
        if: has_cues != 0
      - id: dsp_coefs
        size: 0x2e
        repeat: expr
        repeat-expr: channels
        doc: 16 s2 coefficients plus the 14-byte per-channel state.
  bank_header:
    seq:
      - id: unk0
        size: 12
      - id: count
        type: u2
      - id: unk0e
        size: 18
      - id: sound_offsets
        type: u4
        repeat: expr
        repeat-expr: count
    instances:
      sounds:
        type: sound(_index)
        repeat: expr
        repeat-expr: count
  sound:
    params:
      - id: i
        type: s4
    instances:
      hdr:
        pos: _parent.sound_offsets[i]
        io: _root._io
        type: sound_header
  sound_header:
    seq:
      - id: unk0
        size: 4
      - id: size
        type: u4
      - id: rate
        type: u4
      - id: nibbles
        type: u4
      - id: data_offset
        type: u4
        doc: Relative to the file's data_offset.
      - id: nibbles_alt
        type: u4
        doc: Used when `nibbles` is 0.
      - id: unk18
        size: 16
      - id: coefs
        size: 32
