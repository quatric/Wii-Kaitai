meta:
  id: news_savedata
  title: News Channel - noerase/savedata.dat
  application: News Channel
  file-extension: dat
  endian: be
doc: |
  The News Channel's entire save file. 32 bytes, uncompressed and unencrypted:

      /title/00010002/48414745/data/noerase/savedata.dat

  Same container as the Forecast Channel's - the two channels are built from one
  source tree and share the save code verbatim, differing only in the label and
  the payload. See forecast/forecast_savedata.ksy.

  Validation, in order:

    1. CRC-32 over bytes 0x00-0x1B against the trailer.
       Failure prints "NAND data broken."
    2. The four label bytes against "HAG0".
       Failure prints "NAND data invalid label."
    3. console_language compared against the console's own.
       Mismatch discards the saved preferences.
seq:
  - id: label
    contents: 'HAG0'
    doc: |
      Stored as the bytes 0x48 0x41 0x47 0x30. Forecast
      writes "HAF0"; only the third byte differs, matching the HAF/HAG title IDs.
  - id: console_language
    type: u4
    enum: language
    doc: |
      The console language byte at the time of the save - the same
      global that selects the localized "Error Code:" label.

      On load this must equal the current console language or the save is
      discarded. Where Forecast keys its save to the region word, News keys it
      to the language.
  - id: news_language
    type: u4
    enum: language
    doc: |
      The selected news language, loaded as a single byte.

      Bounds-checked to 0..=6 - values >= 7 or < 0 reject the
      save outright. That range is exactly the seven languages used throughout
      the channel.

      Note: when the channel saves, it writes the console language into both
      this field and console_language, so a save written by the channel always
      has them equal. The loader nonetheless treats console_language
      as the guard and this as the value it installs.
  - id: text_zoom
    type: u4
    doc: |
      Index into a table of eight multipliers:

          0 -> 0.6   1 -> 0.7   2 -> 0.8   3 -> 0.9
          4 -> 1.0   5 -> 1.2   6 -> 1.4   7 -> 1.6

      THIS FIELD IS NOT BOUNDS-CHECKED. The 0..=6 test applies to
      news_language, not to this field, and nothing else constrains it before it
      is used to look up the multiplier. A save with a value outside 0..7 reads a float from
      past the end of an eight-entry table. Label and CRC both pass first, so it
      is reachable with an otherwise well-formed save. Generators must keep this
      in range; the console will not.
  - id: reserved
    size: 12
    doc: |
      Never read, never written - four bytes more than Forecast's eight, because
      News stores one fewer preference in the same 32-byte record. The CRC covers
      them, so write zeros.
  - id: checksum
    type: u4
    doc: |
      CRC-32 over bytes 0x00-0x1B, Standard reflected
      CRC-32: polynomial 0xEDB88320, init 0xFFFFFFFF, final inversion.
enums:
  language:
    0: japanese
    1: english
    2: german
    3: french
    4: spanish
    5: italian
    6: dutch
