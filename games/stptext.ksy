meta:
  id: stptext
  title: Oregon Trail .stp string pack
  file-extension: stp
  endian: le
doc: |
  Tagged sections "PSC", "PSD" (sorted table of u32 string hashes), "PSB"
  (trailer). Texts form a pool of {u32 length, ASCII bytes} records up to the
  PSB tag; the pool start is found heuristically.
seq:
  - id: two_a
    type: u2
  - id: two_b
    type: u2
  - id: size
    type: u4
  - id: hash
    type: u4
  - id: rest
    size-eos: true
types:
  pool_string:
    seq:
      - id: length
        type: u4
      - id: text
        size: length
        type: str
        encoding: ASCII
