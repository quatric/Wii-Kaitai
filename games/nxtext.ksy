meta:
  id: nxtext
  title: Switch / Switch 2 data converted to YAML or JSON
  endian: le
doc: |
  Not a single format: a table of (extension, magic, label, converter) rows in
  nxtext.inc. Each underlying binary has its own definition (aamp, byml, bfsar,
  bfevfl, baev, xlnk, zeldabake, tera, mcpk, ...).
seq:
  - id: data
    size-eos: true
