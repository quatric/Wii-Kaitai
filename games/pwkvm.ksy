meta:
  id: pwkvm
  title: Pipeworks PWK script files (.pvd / .mcl)
  endian: be
doc: |
  Monster High Ghoul Spirit. Start with "PWK <kind> v<version> (big endian)
  \x1a\0" followed by big-endian size/offset fields. Bytecode and class
  records are not decoded.
seq:
  - id: magic
    contents: "PWK "
  - id: header_line
    type: strz
    encoding: ASCII
  - id: rest
    size-eos: true
