meta:
  id: phive
  title: Phive collision shape (.bphsh / .bphsc)
  file-extension: bphsh
  endian: le
doc: |
  Splatoon 3 and later. A small little-endian header ("Phive\0"), a big-endian
  Havok tag file (TAG0) holding one hknpMeshShape in its in-memory layout
  (relative arrays/pointers, 16-bit quantized vertices in sections of up to 256
  vertices), and two material tables (material id + flags, collision-disable
  flags). Static compound bodies (.bphsc, container version 2.2) hold
  hknpCompoundShape instances.
seq:
  - id: magic
    contents: ["Phive", 0]
  - id: rest
    size-eos: true
