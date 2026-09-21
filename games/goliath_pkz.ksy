meta:
  id: goliath_pkz
  file-extension: pkz
  endian: be
  title: Goliath engine GS package (Skylanders SuperChargers Racing, Wii)
doc: |
  Hierarchical chunk-tree container, ported from nintoolbox's
  `lib-goliath.c`/`lib-goliath.h`. Every retail `Data/*.pkz` file is a
  single top-level `0x80000001` chunk whose payload size equals
  `filesize - 16`; the whole file is walked recursively, one uniform
  16-byte header per chunk.

  Unrelated to the PlatinumGames `.pkz` archive (magic `pkz\0`) already
  supported elsewhere in this project -- the two only share an extension.

  Notable chunk ids (not separately typed here, since their payload
  layouts vary by id): `0x8000138d` generic named-resource wrapper (whose
  first child `0x8000138e` is a 92-byte record: hash u32 at 0x00, name
  string at 0x1c/64 bytes); `0x80000191` -> `0x80000197` 48-byte texture
  header (height, width, mipmaps low byte, format, nominal colour-chain
  size, then sampler state); `0x80000195` paired GameCube-tiled mip chain
  payload; `0x80001133` audio stream description; `0x80001134` paired
  big-endian RIFX/WAVE DSP-ADPCM payload. Bulk texture/audio payloads are
  pooled under `0x80000026` and matched to their descriptions positionally
  in document order, not by any in-file reference.
seq:
  - id: root
    type: chunk
types:
  chunk:
    seq:
      - id: id
        type: u4
        doc: Chunk type; the high bit is always set.
      - id: version
        type: u2
        doc: Per-type record version.
      - id: has_children
        type: u2
        doc: 0 = payload is opaque bytes, 1 = payload is a run of child chunks.
      - id: size_hi
        type: u4
        doc: High word of the payload size; 0 in every observed sample.
      - id: size
        type: u4
        doc: Payload byte length, not counting this 16-byte header.
      - id: payload
        size: size
  texture_header:
    doc: Body of a 0x80000197 chunk (child of 0x80000191, child of 0x8000138d).
    seq:
      - id: height
        type: u4
      - id: width
        type: u4
      - id: mipmaps_raw
        type: u4
        doc: Only the low byte is the mip level count.
      - id: format
        type: u4
        doc: |
          2 = RGB5A3 (16bpp, full mip chain); 3 = CMPR full mip chain;
          4 = CMPR mip chain + a following independent I8 alpha mip chain;
          5 = unresolved, declined by the reader.
      - id: nominal_size
        type: u4
        doc: Byte length of the colour mip chain alone.
      - id: sampler_state
        size: 26
    instances:
      mipmaps:
        value: mipmaps_raw & 0xff
  resource_name_record:
    doc: Body of a 0x8000138e chunk (first child of a 0x8000138d resource wrapper).
    seq:
      - id: hash
        type: u4
      - id: unknown
        size: 24
      - id: name
        type: strz
        encoding: ASCII
        size: 64
