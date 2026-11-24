meta:
  id: forecast_savedata
  title: Forecast Channel - noerase/savedata.dat
  application: Forecast Channel
  file-extension: dat
  endian: be
doc: |
  The Forecast Channel's save file.

  It remembers which city you picked and your unit choices (Celsius or
  Fahrenheit, km/h or mph). That's all. It never holds weather data.

  It lives at /title/00010002/48414645/data/noerase/savedata.dat and is exactly
  32 bytes, not compressed or encrypted. The Wii Menu banner reads it too.

  If the file is damaged (bad checksum or label), the channel ignores it and
  asks for a city again. If it was saved on a console from another region, the
  channel keeps the file but forgets the city. Nothing is fatal.

  Every field is always filled in, so there are no "unused" markers here.

  Deep technical notes (addresses, validation rules): https://gist.github.com/quatric/23267cf80416303da28ef186551a88df
seq:
  - id: label
    contents: 'HAF0'
    doc: Always "HAF0". The channel checks it.
  - id: region_word
    type: u4
    doc: |
      The console's country when the file was saved. Only the top byte is used:
      it is the console's country code (see `console_country_code`) and the other
      three bytes are always 0. If it doesn't match the console now, the saved
      city is ignored.

      If the console has no country set, the channel makes one up from the
      console's region: Japan/Taiwan consoles get 0x01 (Japan), Europe/Australia/
      South Africa consoles get 0x4E (Germany), and everything else (USA, Korea,
      etc.) gets 0x31 (United States).
  - id: location_key
    type: location_key
    doc: |
      The city you picked. Matches the key at the start of the entries in
      forecast.bin and short.bin. With no save, this is just the region word, so
      a new console starts on its country instead of a city (`is_country_only`).
  - id: temperature_unit
    type: u4
    enum: temp_unit
    doc: 0 = Celsius, 1 = Fahrenheit. The Wii Menu banner uses this too.
  - id: wind_speed_unit
    type: u4
    enum: wind_unit
    doc: 0 = mph, 1 = km/h. Not offered on Japanese consoles.
  - id: reserved
    size: 8
    doc: |
      Never read or written on purpose, so a real save can hold leftover junk
      here. It still counts toward the checksum. Write zeros.
  - id: checksum
    type: u4
    doc: |
      CRC-32 of the first 0x1C bytes (the standard zlib one). If it doesn't
      match, the channel says "NAND data broken" and ignores the file.
instances:
  console_country_code:
    value: region_word >> 24
    doc: |
      The console's country code. Same numbers as `country_code` in
      forecast_file.ksy (e.g. 1 = japan, 49 = united_states, 78 = germany).
types:
  location_key:
    doc: |
      A city's ID. Three numbers that together pick one city. The same four
      bytes start every city entry in forecast.bin and short.bin.
    seq:
      - id: country_code
        type: u1
      - id: region_code
        type: u1
      - id: location_code
        type: u2
    instances:
      is_country_only:
        value: region_code == 0 and location_code == 0
        doc: |
          True when only the country is set and no specific city. This is what the
          channel uses when nothing is saved: it starts on the country.
enums:
  temp_unit:
    0: celsius
    1: fahrenheit
  wind_unit:
    0: mph
    1: kmh
