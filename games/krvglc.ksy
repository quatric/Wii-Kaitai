meta:
  id: krvglc
  title: Legend of Spyro Dawn of the Dragon language table (.KRV)
  file-extension: krv
  endian: le
doc: '{u32 5, u32 12, ..} then id tables and runs of length-prefixed strings {u32 chars incl. terminator, UTF-16LE text, 0}; runs are found by scanning.'
seq:
  - id: five
    type: u4
  - id: twelve
    type: u4
  - id: body
    size-eos: true
types:
  string:
    seq:
      - id: chars
        type: u4
      - id: text
        size: chars * 2
        type: str
        encoding: UTF-16LE
