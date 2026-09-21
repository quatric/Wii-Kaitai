meta:
  id: nlg_probe
  endian: le
  title: Next Level Games FEDM/FEDS/FEDT container (Federation Force / LM2 / LM3)
doc: |
  Standalone Next Level Games model/skeleton/texture container, as
  structurally validated by IsNLGModel()/IsNLGSkeleton()/IsNLGTexture()
  in lib-nlg-probe.c. Full parsing of the FEDM/FEDS chunk table lives
  in lib-nlg-lm.c and is not modeled here -- this covers only the
  fully-specified shared FEDM/FEDS header and chunk-size table, plus
  the fully-specified FEDT texture header.
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
    valid:
      any-of: ['"FEDM"', '"FEDS"', '"FEDT"']
  - id: body
    type:
      switch-on: magic
      cases:
        '"FEDT"': fedt_body
        _: fed_container_body
types:
  fed_container_body:
    doc: Shared FEDM (model) / FEDS (skeleton) container shape.
    seq:
      - id: version
        type: u2
        doc: Must be 1..3.
      - id: num_chunks
        type: u2
        doc: Must be 1..4096.
      - id: chunks
        type: fed_chunk_entry
        repeat: expr
        repeat-expr: num_chunks
  fed_chunk_entry:
    doc: 8-byte chunk table entry; only the trailing size field is validated.
    seq:
      - id: unknown
        size: 4
      - id: size
        type: u4
  fedt_body:
    doc: FEDT texture header, fully specified by IsNLGTexture().
    seq:
      - id: version
        type: u2
        doc: Must be 1..3.
      - id: unknown1
        size: 2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: unknown2
        size: 8
      - id: data_size
        type: u4
      - id: data
        size: data_size
