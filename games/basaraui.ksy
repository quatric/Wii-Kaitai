meta:
  id: basaraui
  title: Sengoku Basara 3 UI layout (.lsp) / animation script (.sdl)
  endian: be
doc: '.lsp: "\0PSL", u32 BE version 33; .sdl: "\0LDS". Node and property records are not decoded; strings hold node names, animation names, SDL property names (mSeId...) and texture paths.'
seq:
  - id: magic
    size: 4
    doc: '"\0PSL" or "\0LDS".'
  - id: version
    type: u4
  - id: rest
    size-eos: true
