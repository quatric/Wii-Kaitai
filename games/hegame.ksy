meta:
  id: hegame
  title: Humongous Entertainment SCUMM HE resource file (.(a), XOR 0x69)
  imports:
    - /games/scumm_he
doc: |
  The whole file is XORed with 0x69; decoded it is a chain "LECF" > "LFLF"
  (one per room) > resource blocks, i.e. the `scumm_he` block layout.
seq:
  - id: body
    size-eos: true
    process: xor(0x69)
    type: scumm_he
