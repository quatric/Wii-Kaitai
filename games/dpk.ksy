meta:
  id: dpk
  title: Simple Wii Series package (data.dpk)
  file-extension: dpk
  endian: le
doc: |
  Simple Wii Series `.dpk` package. After the header come directory nodes (u32
  words, then the NUL-terminated backslash path of the node) and, up to the
  table end, one record per file `{u32 offset of the part inside its bundle,
  u32 unpacked size, NUL-terminated name}`. A node that ends in `{u32 bundle
  offset (0x800 aligned), u32 bundle size, u32 parent node, u32 0 or 8, u32
  file count (nonzero)}` is a bundle. A bundle is `Wpbb`, u32 part count, then
  `{u32 offset, u32 size}` per part; a part is either a `Wp16` stream (u32
  unpacked size; 32 flag bits then 32 words; flag 1 = literal word, flag 0 =
  codeword `dddddddddddccccc`: copy c+2 words from d words back) or stored data.
seq:
  - id: table_end
    type: u4
  - id: num_nodes
    type: u4
  - id: num_files
    type: u4
