meta:
  id: dls
  title: Downloadable Sounds bank (.dls, RIFF "DLS ")
  file-extension: dls
  endian: le
doc: |
  Every entry of the "LIST wvpl" wave pool is a "LIST wave" with a "fmt " and a
  "data" chunk and an optional INFO/INAM name. Instrument, region and
  articulation data (lins, ptbl) are not modelled.
seq:
  - id: magic
    contents: RIFF
  - id: size
    type: u4
  - id: form_type
    contents: "DLS "
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
      - id: pad
        size: size % 2
