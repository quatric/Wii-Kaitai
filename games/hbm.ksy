meta:
  id: hbm
  title: Home Button Menu data (.hbm)
  file-extension: hbm
  endian: be
doc: |
  Home Button Menu data (`nativeWii/system/homebutton/*.hbm`, e.g. Sengoku
  Basara). The five offsets point at back-to-back sections: resource U8
  archive, UTF-16 message table, text index, a second U8 archive; the last
  section runs to the end of the file.
seq:
  - id: magic
    contents: [0, 'MBH']
  - id: version
    type: u4
    doc: 4.
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: 5
