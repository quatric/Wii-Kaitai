meta:
  id: momomessage
  title: Momotarou Dentetsu 16 message.bin
  file-extension: bin
  endian: be
doc: |
  Starts with a glyph catalogue (0x0110..0x0119, 0x0c 0x0f 0x00, 0x011a ...). Text
  is a stream of BE 16-bit glyph codes 0x01xx / 0x02xx (font pages); control: 0x0c
  line break, 0x0c 0x0f 0x00 block break, 0x0a XX and 0x05 XX one-byte commands.
  Known glyphs: 0x110 digits, 0x124 space, 0x125 '!', 0x128 A-Z, 0x142 a-z, 0x15c
  hiragana (81), 0x1ad katakana (81); everything else is kanji pages.
seq:
  - id: codes
    type: u2
    repeat: eos
