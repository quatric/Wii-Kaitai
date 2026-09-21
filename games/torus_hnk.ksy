meta:
  id: torus_hnk
  endian: le
  title: Torus Games hunkfile (.hnk, Wii)
doc: |
  Torus Games "hunkfile" (.hnk), per lib-torus.h. A flat run of
  little-endian chunks; per-class payload layouts (TSETexture,
  SqueakStream) are documented in the source but only the generic
  chunk stream is modeled here.
seq:
  - id: chunks
    type: chunk_t
    repeat: eos
types:
  chunk_t:
    seq:
      - id: size
        type: u4
      - id: kind
        type: u2
        doc: Bits 12-15 select a memory pool; low 12 bits are the record type.
      - id: unknown_06
        type: u2
      - id: payload
        size: size
