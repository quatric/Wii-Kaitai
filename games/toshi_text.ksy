meta:
  id: toshi_text
  title: Blue Tongue Toshi locale strings (.trb, Barnyard Wii)
  endian: be
doc: |
  Data/Locale/<lang>.trb "LocaleStrings" symbol {s32 count, u32 ptr to count
  string pointers}; strings are UTF-16BE in the TSFB section.
seq:
  - id: count
    type: s4
  - id: strings_ptr
    type: u4
