meta:
  id: rtex
  title: NW4R intermediate texture (.rtex, XML)
  file-extension: rtex
doc: |
  XML "nw4r_3dif" tool export: <image format="cmpr|rgba8|rgb565|rgb5a3|ia8|i8|i4|
  ia4" palette_name="" width= height= mipmap_level= data_unit="u32|u16|u8"
  data_size= path=> followed by whitespace-separated BE hex words of the GX
  texture data (base level first).
seq:
  - id: text
    size-eos: true
    type: str
    encoding: ASCII
