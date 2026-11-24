meta:
  id: mh2_mls
  title: Manhunt 2 script list (.mls)
  file-extension: mls
  endian: be
doc: |
  Rockstar Leeds script list (Manhunt 2 `.mls`). Each chunk body starts with an
  `SCPT` section `{u32 section size, NUL-padded script name}` (`oncreate`,
  `onenter`, ...) and holds the compiled script of one level event.
seq:
  - id: magic
    contents: MHLS
  - id: version_a
    type: u2
    doc: 9.
  - id: version_b
    type: u2
    doc: 3.
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        contents: MHSC
      - id: len_body
        type: u4
      - id: body
        size: len_body
