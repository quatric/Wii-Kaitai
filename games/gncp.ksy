meta:
  id: gncp
  title: Sonic Team CPAF GUI package (.gncp, Secret Rings / Black Knight)
  file-extension: gncp
  endian: be
doc: |
  "CPAF" package: 0x20-byte head, a chunked 2D layout ("NGIF", "nCPJ", ".TXL",
  "NGTL", ...) and then the textures it uses as complete GVR files stored back
  to back. The layout chunks are not decoded. nintoolbox locates the textures by
  scanning for "GCIX"/"GBIX" with "GVRT" at +0x10, because the exact texture
  start is not recorded in a field known to be reliable; `gvr_texture` below
  gives the framing so a caller can parse from that offset
  (`pos` = scanned offset, `type: gvr_texture`, repeat until EOF).
  Not validated against a real file (none available locally).
seq:
  - id: magic
    contents: CPAF
  - id: layout_size
    type: u4
    doc: Size of the layout part (must not exceed the file size).
  - id: head_rest
    size: 0x18
  - id: body
    size-eos: true
types:
  gvr_texture:
    seq:
      - id: gix_tag
        size: 4
        doc: '"GCIX" or "GBIX".'
      - id: gix_rest
        size: 12
      - id: gvrt_tag
        contents: GVRT
      - id: payload_size
        type: u4le
        doc: Bytes after this field; total texture length is 0x18 + this.
      - id: payload
        size: payload_size
