meta:
  id: lua51_be
  title: Big-endian Lua 5.1 bytecode (.luac / .lub / .compiledLuaWii)
  endian: be
doc: |
  Header 1B 4C 75 61 51 00 (version 0x51, format 0) then endianness flag 0; Wii
  builds use 4-byte int / 4-byte size_t / 4-byte instruction / 4-byte float
  number (Sleepover Party).
seq:
  - id: signature
    contents: [0x1b, "Lua"]
  - id: version
    type: u1
    doc: 0x51.
  - id: format
    type: u1
  - id: endianness
    type: u1
    doc: 0 = big endian.
  - id: size_int
    type: u1
  - id: size_size_t
    type: u1
  - id: size_instruction
    type: u1
  - id: size_number
    type: u1
  - id: integral_flag
    type: u1
  - id: function
    size-eos: true
