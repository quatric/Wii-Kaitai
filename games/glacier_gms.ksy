meta:
  id: glacier_gms
  title: IO Interactive Glacier scene geometry (.gms)
  file-extension: gms
  endian: le
doc: Mini Ninjas. Raw deflate stream inflating to the stated size; the result is a big-endian object graph.
seq:
  - id: decompressed_size
    type: u4
  - id: file_size
    type: u4
  - id: zero
    type: u1
  - id: deflate_stream
    size-eos: true
