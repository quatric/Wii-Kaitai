meta:
  id: sasrefpack
  title: EA Tiger Woods swing-capture stream (.sas)
  file-extension: sas
doc: |
  Chain of independent RefPack ("10 fb" + 24-bit size) chunks, each starting on a
  0x800 boundary (next chunk = end of the stream's terminator opcode rounded up to
  0x800). Record layout inside is not decoded.
seq:
  - id: marker
    contents: [0x10, 0xfb]
  - id: size
    type: b24be
  - id: rest
    size-eos: true
