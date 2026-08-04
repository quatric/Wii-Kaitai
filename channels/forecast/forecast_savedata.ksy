meta:
  id: forecast_savedata
  title: Forecast Channel - noerase/savedata.dat
  application: Forecast Channel
  file-extension: dat
  endian: be
doc: |
  The Forecast Channel's entire save file. 32 bytes, stored uncompressed and
  unencrypted at:

      /title/00010002/48414645/data/noerase/savedata.dat

  It holds the chosen city and the two unit toggles - nothing else. Weather data
  itself is cached separately in Forecast.dat and wc24dl.vff.

  Validation, in the order the console applies it (loader at 0x8000BAD4):

    1. CRC-32 over bytes 0x00-0x1B compared against the trailer (0x8000BB84).
       Failure prints "NAND data broken."
    2. The four label bytes, one at a time, against the constant "HAF0" stored
       at 0x803319E8 (0x8000BBB0-0x8000BC44).
       Failure prints "NAND data invalid label."
    3. region_word compared against the console's own (0x8000FFA4).
       Mismatch does not reject the file - it just discards the saved city.

  Neither failure is fatal. A rejected save means the channel asks the user to
  pick a city again.

  The News Channel uses this exact container with the label "HAG0" and a
  different payload; see news/news_savedata.ksy.
seq:
  - id: label
    contents: 'HAF0'
    doc: |
      Written one byte at a time at 0x8000BDD0 as 0x48 0x41 0x46 0x30. "HAF" is
      the channel's title ID prefix; "0" appears to be a format version, though
      nothing in the binary accepts any other value.
  - id: region_word
    type: u4
    doc: |
      The console region word (r13-0x6A08) at the time of the save, whose TOP
      BYTE is the country code - the same value the download URL formats with
      %03d after `srwi r30, r0, 0x18` at 0x8000ACAC.

      On load this must equal the console's current region word or the saved
      location is ignored. So the save is keyed to the whole region word:
      change region and the stored city is discarded rather than misresolved.
  - id: location_key
    type: location_key
    doc: |
      The selected city. Looked up by 0x80020300, which walks the location
      table comparing the first u32 of each entry against this field - so it is
      directly comparable to the packed key every table in forecast.bin and
      short.bin begins with.

      When no valid save exists this defaults to the bare region word
      (0x8000E0E4), which is why a fresh console lands on the country rather
      than on a city.
  - id: temperature_unit
    type: u4
    enum: temp_unit
    doc: |
      Toggled at 0x80028714 with the cntlzw/srwi-5 logical-NOT idiom, so only
      0 and 1 ever occur. Default comes from a region byte at 0x8000E0EC: one
      branch writes (temperature, wind) = (1, 0), the other (0, 1).

      The Fahrenheit/Celsius naming is inferred from that pairing with the
      wind unit, whose polarity IS pinned by the binary - see wind_speed_unit.
  - id: wind_speed_unit
    type: u4
    enum: wind_unit
    doc: |
      Toggled at 0x80028754, and gated on the console language byte being
      non-zero (lbz r0, -0x6A0A(r13) at 0x80028734) - so this toggle is not
      offered on Japanese systems.

      Polarity is exact, from the rendering code at 0x8001E1DC: value 0 reads
      the long entry's +0x18 (mph), value 1 reads +0x17 (km/h).
  - id: reserved
    size: 8
    doc: |
      Eight bytes that no code path reads and no code path writes. The buffer is
      allocated with `li r3, 0x20; li r4, 0x20; bl 0x80032580` at 0x8000D8F8 and
      the save routine fills only 0x00-0x13 plus the trailer, so on a first save
      these carry whatever the allocator left behind.

      The CRC covers them. Write zeros, and do not assume a retail save has
      zeros here.
  - id: checksum
    type: u4
    doc: |
      CRC-32 over bytes 0x00-0x1B - standard reflected CRC-32: polynomial
      0xEDB88320, initial value 0xFFFFFFFF, final inversion (`nor r3, r8, r8`
      at 0x80067E70). Implemented nibble-at-a-time at 0x80067D44 with the
      16-entry table at 0x80193D60, whose first words are 00000000 1DB71064
      3B6E20C8 26D930AC.
types:
  location_key:
    doc: |
      The packed location key, identical in layout to the first four bytes of
      every forecast.bin and short.bin table entry. Compared as a single
      big-endian u4 by the console.
    seq:
      - id: country_code
        type: u1
      - id: region_code
        type: u1
      - id: location_code
        type: u2
enums:
  temp_unit:
    0: celsius
    1: fahrenheit
  wind_unit:
    0: mph
    1: kmh
