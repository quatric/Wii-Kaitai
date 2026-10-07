meta:
  id: petz_ttpl
  title: Petz engine TTPL texture
  endian: be
doc: |
  Petz-engine "TTPL" texture (Petz Sports, Petz Dogz / Horsez, ...): an 8-byte
  `{"TTPL", u4 size}` wrapper around an ordinary Wii TPL (`0x0020af30`).
seq:
  - id: magic
    contents: 'TTPL'
  - id: size
    type: u4
  - id: tpl
    size: size
    doc: A standard Wii TPL file.
