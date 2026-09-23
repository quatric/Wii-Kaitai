meta:
  id: torus_hnk
  endian: le
  title: Torus Games hunkfile (.hnk, Wii)
doc: |
  Torus Games "hunkfile" (.hnk), per lib-torus.h/.c (ported from
  IsTorusHnk()/ListTorusHnk()). A flat run of little-endian chunks
  ending exactly at end of file. `kind`'s low 12 bits select the
  record type; bits 12-15 select a memory pool and are not modeled.

  An asset is a name chunk (0x071) immediately followed by two payload
  chunks whose kinds and class string identify what they hold:
  `TSETexture` pairs kind 0x150 (header) with 0x151 (the full GX mip
  chain -- CMPR/RGBA8/I8, told apart by matching the chain's byte size),
  and `SqueakStream` pairs kind 0x092 (header, `IWAR` tag) with 0x093
  (a NUL-terminated raw-file name pointing into the sibling SOUND
  folder; that raw file is plain DSP-ADPCM, stereo storing channel 1 in
  the first half and channel 2 in the second). Other kinds (e.g. 0x070
  file header, 0x072 end-of-asset marker) are only exposed as generic
  chunks here.
seq:
  - id: chunks
    type: chunk_t
    repeat: eos
types:
  chunk_t:
    seq:
      - id: size
        type: u4
      - id: kind_raw
        type: u2
        doc: Bits 12-15 select a memory pool; low 12 bits are the record type.
      - id: unknown_06
        type: u2
      - id: payload
        size: size
        type:
          switch-on: kind
          cases:
            0x071: asset_name_t
            0x150: texture_header_t
            0x092: stream_header_t
            0x093: stream_raw_name_t
    instances:
      kind:
        value: kind_raw & 0xfff
      pool:
        value: kind_raw >> 12
  asset_name_t:
    doc: >-
      0x071 asset-name chunk. Identifies the class ("TSETexture",
      "SqueakStream", ...) and asset name of the two payload chunks
      that follow it in the chunk stream.
    seq:
      - id: unknown_00
        type: u2
        doc: Always observed as 1.
      - id: type_id
        type: u2
      - id: chunk_count
        type: u2
        doc: Number of payload chunks belonging to this asset (2 for the known classes).
      - id: len_class
        type: u2
        doc: Byte length of `class_name`, including its terminating NUL.
      - id: len_name
        type: u2
        doc: Byte length of `asset_name`, including its terminating NUL.
      - id: class_name
        type: strz
        encoding: ASCII
        doc: Asset class, e.g. "TSETexture" or "SqueakStream".
      - id: asset_name
        type: strz
        encoding: ASCII
  texture_header_t:
    doc: >-
      0x150 `TSETexture` header. Big-endian fields despite the
      surrounding little-endian chunk stream; immediately followed by
      a 0x151 chunk holding the raw GX mip chain (`tr_chain()` in
      lib-torus.c distinguishes CMPR/RGBA8/I8 by matching the chain's
      exact byte size against `width`/`height`/`mip_count`).
    seq:
      - id: unknown_00
        size: 12
      - id: width
        type: u2be
      - id: height
        type: u2be
      - id: unknown_10
        size: 26 - 16
      - id: mip_count
        type: u1
  stream_header_t:
    doc: >-
      0x092 `SqueakStream` header ("IWAR" tag). Big-endian fields;
      DSP-ADPCM coefficients follow for channel 1 at +64 and, for
      stereo, channel 2 at +112.
    seq:
      - id: magic
        contents: "IWAR"
      - id: unknown_04
        size: 2
      - id: channels
        type: u1
      - id: unknown_07
        type: u1
      - id: samples
        type: u4be
      - id: rate
        type: u4be
      - id: unknown_10
        size: 64 - 16
      - id: coefficients_ch1
        type: s2be
        repeat: expr
        repeat-expr: 16
      - id: coefficients_ch2
        type: s2be
        repeat: expr
        repeat-expr: 16
        if: channels == 2
  stream_raw_name_t:
    doc: >-
      0x093 chunk following a stream header. A leading u32 0x40 (mono
      streams) or two u32s 0x40/0x70 (stereo streams), then the
      NUL-terminated name of the sibling raw DSP-ADPCM file in
      ../SOUND. The two shapes are told apart here by whether a second
      u32 still leaves room for at least one more byte (the name and
      its NUL) inside this chunk's declared size, since the channel
      count itself lives in the preceding 0x092 chunk.
    seq:
      - id: unknown_00
        type: u4
      - id: unknown_04
        type: u4
        if: _parent.size > 8
      - id: raw_name
        type: strz
        encoding: ASCII
