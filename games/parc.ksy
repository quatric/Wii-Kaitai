meta:
  id: parc
  title: Kirby Air Riders phx asset catalog (PARC) and PDAT packs
  file-extension: cat
  endian: le
doc: |
  Asset/assets.cat ("PARC"): 64-bit asset IDs, per-asset block lists ("Main",
  "HEAD", "BODY", "GBuf", "$DEP", ...) and a location table {pack, codec (0 raw /
  1 zstd), offset, sizes, SHA-256}. Records are flatbuffers whose identifier at
  +4 names the type (PTEX, PMSH, PANM, PSND, PMTR, PMAP, PEFF, ...). Names are
  hashed; files are named by ID. Assets live in Asset/assets_*.dat ("PDAT").
seq:
  - id: magic
    contents: PARC
  - id: rest
    size-eos: true
