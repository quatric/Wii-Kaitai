meta:
  id: forecast_file
  title: Forecast Channel - forecast.bin
  file-extension: bin
  application: Forecast Channel
  endian: be
doc: |
  forecast.bin: the weather forecast for every city.

  The file is a header followed by seven tables. The header says where each
  table starts and how many entries it has.

    long_forecast_table            cities in the console's own country (full forecast)
    short_forecast_table           cities in other countries (today and tomorrow only)
    weather_condition_codes_table  weather code -> icon number and name
    uv_index_table                 UV code -> text
    laundry_index_table            laundry code -> text (Japan only)
    pollen_count_table             pollen code -> text (Japan only)
    location_table                 the list of cities

  Good to know:
    * Times are minutes since 1 January 2000 (UTC). The `*_unix` fields convert them.
    * The file is stored LZ10-compressed. Everything here describes the
      decompressed file.
    * short_forecast_table is NOT the file short.bin. short.bin is a separate
      file for current weather (see forecast_file_short.ksy).
    * The channel rejects the whole file if the checksum, size, language or
      any code lookup is wrong, and shows error FORE000006.

  "UNUSED" MARKERS. When a field has nothing to say, it is filled with an
  all-ones value instead of 0. Check for it before using the field:

    Field                                     Means "unused" when it is
    ----------------------------------------  --------------------------
    weather codes (forecast, six_hour_forecast)   0xFFFF
    precipitation (six_hour_precipitation, week)  0xFF
    temperatures (high_*, low_*)                  -128
    temperature changes (*_difference)            -128
    wind speeds (km/h and mph)                    0xFF  (shown as `--`)
    wind_direction                                0xFF  (`unused` in the enum)
    uv_index, laundry_index, pollen_count         0xFF  (`unused` in the enum)
    message_offset                                0
    region_text_offset, country_text_offset       0

  Deep technical notes (addresses, validation rules): https://gist.github.com/quatric/23267cf80416303da28ef186551a88df
seq:
  - id: version
    type: u4
    doc: Always 0. Anything else and the channel gives up on the file.
  - id: filesize
    type: u4
    doc: Size of the whole file, after decompressing.
  - id: crc32
    type: u4
    doc: CRC-32 checksum of everything after this field.
  - id: opening_timestamp
    type: u4
    doc: When the file was made (minutes since 2000, UTC). The channel doesn't use it.
  - id: closing_timestamp
    type: u4
    doc: |
      When the file expires (minutes since 2000, UTC). After this the channel
      throws the file away and downloads a new one. WiiLink sets it to opening + 90.
  - id: country_code
    type: u1
    enum: country_code
    doc: The country this file is for.
  - id: unknown_1
    type: u1
    repeat: expr
    repeat-expr: 3
    doc: Padding. Never read.
  - id: language_code
    type: u1
    enum: language_code
    doc: |
      Language of the text in the file. Must match the console's language, or
      the channel rejects the file. So there is one file per language.
      The channel only supports these seven. If the console is set to any other
      language, the channel treats it as English (and switches the console's
      own language setting to English too).
  - id: region_flag
    type: u1
    enum: region_flag
    doc: |
      Picks the default units when the user hasn't saved a choice:
      fahrenheit = Fahrenheit and mph, celsius or japan = Celsius and km/h.
  - id: unknown_2
    type: u1
    doc: Must be 0 or 1. Checked, but nothing uses it. WiiLink writes 1.
  - id: padding
    type: u1
  - id: message_offset
    type: u4
    doc: |
      Where a service message (UTF-16BE text) starts, or 0 for none. If set, the
      channel shows this message instead of the forecast. Keep it under 512
      characters.
  - id: long_forecast_pointer
    type: table_pointer
    doc: The long_forecast_table.
  - id: short_forecast_pointer
    type: table_pointer
    doc: The short_forecast_table.
  - id: weather_condition_codes_pointer
    type: table_pointer
    doc: The weather_condition_codes_table. Can't be empty.
  - id: uv_index_pointer
    type: table_pointer
    doc: The uv_index_table.
  - id: laundry_index_pointer
    type: table_pointer
    doc: The laundry_index_table.
  - id: pollen_count_pointer
    type: table_pointer
    doc: The pollen_count_table.
  - id: location_pointer
    type: table_pointer
    doc: The location_table. Can't be empty.
instances:
  opening_unix:
    value: (opening_timestamp + 15778080) * 60
    doc: The time the file was made as a normal Unix time (seconds since 1970).
  closing_unix:
    value: (closing_timestamp + 15778080) * 60
    doc: The time the file expires as a normal Unix time (seconds since 1970).
  long_forecast_table:
    pos: long_forecast_pointer.offset
    type: long_forecast_table
    repeat: expr
    repeat-expr: long_forecast_pointer.entry_count
  short_forecast_table:
    pos: short_forecast_pointer.offset
    type: short_forecast_table
    repeat: expr
    repeat-expr: short_forecast_pointer.entry_count
  weather_condition_codes_table:
    pos: weather_condition_codes_pointer.offset
    type: weather_condition_codes_table
    repeat: expr
    repeat-expr: weather_condition_codes_pointer.entry_count
  uv_index_table:
    pos: uv_index_pointer.offset
    type: uv_index_table
    repeat: expr
    repeat-expr: uv_index_pointer.entry_count
  laundry_index_table:
    pos: laundry_index_pointer.offset
    type: laundry_index_table
    repeat: expr
    repeat-expr: laundry_index_pointer.entry_count
  pollen_count_table:
    pos: pollen_count_pointer.offset
    type: pollen_count_table
    repeat: expr
    repeat-expr: pollen_count_pointer.entry_count
  location_table:
    pos: location_pointer.offset
    type: location_table
    repeat: expr
    repeat-expr: location_pointer.entry_count
types:
  location_key:
    doc: |
      A city's ID. Three numbers that together pick one city. Every table entry
      that belongs to a city starts with these same four bytes.
    seq:
      - id: country_code
        type: u1
        enum: country_code
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
  table_pointer:
    doc: Says where a table is in the file and how many entries it has.
    seq:
      - id: entry_count
        type: u4
        doc: Number of entries. 0 means the table is empty.
      - id: offset
        type: u4
        doc: Where the first entry starts, counted in bytes from the start of the file.
  long_forecast_table:
    doc: |
      One city's full forecast (0x80 bytes): today, tomorrow, then seven more days.
      Used for cities in the console's own country.
    seq:
      - id: key
        type: location_key
        doc: Which city this is.
      - id: local_timestamp
        type: u4
        doc: When the forecast was issued, in the city's local time (minutes since 2000).
      - id: global_timestamp
        type: u4
        doc: The same moment in UTC (minutes since 2000).
      - id: timezone_tag
        type: u1
        doc: |
          Must be 0 to 5, or 0xFF. Nothing uses it. Nintendo's files have 1 for
          most cities, 4 or 5 for a few, and 0xFF in Japan.
      - id: timezone_tag_reserved
        size: 3
        doc: Padding. Never read.
      - id: today
        type: day_block
      - id: tomorrow
        type: day_block
      - id: week
        type: week_day
        repeat: expr
        repeat-expr: 7
        doc: |
          The next seven days, starting the day after tomorrow. Only the first
          five are shown outside Japan; days 6 and 7 are Japan only.
    instances:
      utc_offset_minutes:
        value: local_timestamp - global_timestamp
        doc: How far the city's clock is from UTC, in minutes (-300 means UTC-5).
  short_forecast_table:
    doc: |
      One city's short forecast (0x48 bytes): today and tomorrow only. Used for
      cities in other countries.
    seq:
      - id: key
        type: location_key
        doc: Which city this is.
      - id: local_timestamp
        type: u4
        doc: When the forecast was issued, in the city's local time (minutes since 2000).
      - id: global_timestamp
        type: u4
        doc: The same moment in UTC (minutes since 2000).
      - id: timezone_tag
        type: u1
        doc: Same as in long_forecast_table. Nothing uses it.
      - id: timezone_tag_reserved
        size: 3
        doc: Padding. Never read.
      - id: today
        type: day_block
        doc: |
          In this table the UV, laundry and pollen bytes are checked but never
          shown. WiiLink fills today's with 0xFF (unused).
      - id: tomorrow
        type: day_block
    instances:
      utc_offset_minutes:
        value: local_timestamp - global_timestamp
        doc: How far the city's clock is from UTC, in minutes (-300 means UTC-5).
  day_block:
    doc: |
      One day of forecast (0x1C bytes). Every long and short entry has two:
      today, then tomorrow.
    seq:
      - id: forecast
        type: u2
        doc: Weather code for the whole day. 0xFFFF means unused.
      - id: six_hour_forecast
        type: u2
        repeat: expr
        repeat-expr: 4
        doc: |
          Weather codes for 12am-6am, 6am-12pm, 12pm-6pm and 6pm-12am, in that
          order. 0xFFFF means unused.
      - id: high_celsius
        type: s1
        doc: Highest temperature in Celsius. -128 means unused.
      - id: high_celsius_difference
        type: s1
        doc: Japan only. How much the high changed since yesterday. -128 means unused.
      - id: low_celsius
        type: s1
        doc: Lowest temperature in Celsius. -128 means unused.
      - id: low_celsius_difference
        type: s1
        doc: Japan only. How much the low changed since yesterday. -128 means unused.
      - id: high_fahrenheit
        type: s1
        doc: Highest temperature in Fahrenheit. -128 means unused.
      - id: high_fahrenheit_difference
        type: s1
        doc: Japan only. How much the high changed since yesterday. -128 means unused.
      - id: low_fahrenheit
        type: s1
        doc: Lowest temperature in Fahrenheit. -128 means unused.
      - id: low_fahrenheit_difference
        type: s1
        doc: Japan only. How much the low changed since yesterday. -128 means unused.
      - id: six_hour_precipitation
        type: u1
        repeat: expr
        repeat-expr: 4
        doc: |
          Japan only. Chance of rain or snow (0-100 %) for 12am-6am, 6am-12pm,
          12pm-6pm and 6pm-12am, in that order. 0xFF means unused (shown as `--`).
      - id: wind_direction
        type: u1
        enum: wind_direction
        doc: |
          Which way the wind blows. `calm` is no wind, `unused` hides the wind row.
          With `calm`, consoles in region group 1 (USA, Korea, etc.) show just the
          speed; other consoles show the word for "calm" and no speed.
      - id: wind_speed_kilometers_per_hour
        type: u1
        doc: Wind speed in km/h. 0xFF means unused (shown as `--`).
      - id: wind_speed_miles_per_hour
        type: u1
        doc: Wind speed in mph. 0xFF means unused (shown as `--`).
      - id: uv_index
        type: u1
        enum: index_code
        doc: |
          UV level, a code from uv_index_table. 0xFF (`unused`) means none.
          Only today's value is shown, and not for short entries.
      - id: laundry_index
        type: u1
        enum: index_code
        doc: |
          Japan only. Laundry level, a code from laundry_index_table. 0xFF means
          none. Only checked and shown on region group 0 consoles (Japan, Taiwan).
      - id: pollen_count
        type: u1
        enum: index_code
        doc: |
          Japan only. Pollen level, a code from pollen_count_table. 0xFF means
          none. Only checked and shown on region group 0 consoles (Japan, Taiwan).
    instances:
      forecast_is_unused:
        value: (forecast & 0x7fff) == 999 or (forecast & 0x7fff) == 0x7fff
        doc: True when `forecast` is the "no weather" marker.
  week_day:
    doc: One day of the seven-day outlook (8 bytes). Every long entry ends with seven.
    seq:
      - id: forecast
        type: u2
        doc: Weather code. 0xFFFF means unused.
      - id: high_celsius
        type: s1
        doc: Highest temperature in Celsius. -128 means unused.
      - id: low_celsius
        type: s1
        doc: Lowest temperature in Celsius. -128 means unused.
      - id: high_fahrenheit
        type: s1
        doc: Highest temperature in Fahrenheit. -128 means unused.
      - id: low_fahrenheit
        type: s1
        doc: Lowest temperature in Fahrenheit. -128 means unused.
      - id: precipitation
        type: u1
        doc: Japan only. Chance of rain or snow, 0-100 %. 0xFF means unused (shown as `--`).
      - id: padding
        type: u1
        doc: Padding. Never read.
    instances:
      forecast_is_unused:
        value: (forecast & 0x7fff) == 999 or (forecast & 0x7fff) == 0x7fff
        doc: True when `forecast` is the "no weather" marker.
  weather_condition_codes_table:
    doc: |
      Turns a weather code into an icon and a name. WiiLink writes two entries
      per condition: an international one and a Japanese one.
    seq:
      - id: weather_icon_code_1
        type: u2
        doc: |
          The code the other tables use for this weather. Must be unique.
          0xFFFF, 0x7FFF and 999 all mean "no weather".
      - id: weather_icon_code_2
        type: u2
        doc: |
          Which icon to draw. The low 15 bits are the icon number (1-33 Japanese
          icons, 101-126 international). The top bit means "night version".
          The channel also uses the icon number to pick rain and thunder sound
          effects (see `plays_rain_sound`).
      - id: weather_text_offset
        type: u4
        doc: Where the weather's name starts (UTF-16BE text, e.g. "Sunny"). Can't be 0.
    instances:
      icon_id:
        value: weather_icon_code_2 & 0x7fff
        doc: The icon number, without the night bit.
      is_night:
        value: (weather_icon_code_2 & 0x8000) != 0
        doc: True if the night version of the icon is used.
      is_international_icon:
        value: icon_id >= 100
        doc: True for the international icon set (100 and up). The Japanese icons are 1-33.
      plays_thunder_sound:
        value: icon_id == 5 or icon_id == 9 or icon_id == 14 or icon_id == 18 or icon_id == 125
        doc: True if the channel plays thunder (and rain) sounds for this icon.
      plays_rain_sound:
        value: plays_thunder_sound or icon_id == 3 or icon_id == 7 or icon_id == 12 or icon_id == 16 or icon_id == 19 or icon_id == 20 or icon_id == 21 or icon_id == 22 or icon_id == 23 or icon_id == 24 or icon_id == 25 or icon_id == 31 or icon_id == 32 or icon_id == 103 or icon_id == 105 or icon_id == 108 or icon_id == 110 or icon_id == 111 or icon_id == 112 or icon_id == 113 or icon_id == 114 or icon_id == 115 or icon_id == 119 or icon_id == 120 or icon_id == 121
        doc: True if the channel plays a rain sound for this icon (thunder icons included).
  uv_index_table:
    doc: Turns a UV code into text.
    seq:
      - id: uv_index_code
        type: u1
        doc: The code used by uv_index in day_block. Must be unique.
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: Padding. Never read.
      - id: uv_index_text_offset
        type: u4
        doc: Where the text starts (UTF-16BE).
  laundry_index_table:
    doc: Turns a laundry code into text. Only checked on region group 0 consoles (Japan, Taiwan).
    seq:
      - id: laundry_index_code
        type: u1
        doc: The code used by laundry_index in day_block. Must be unique.
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: Padding. Never read.
      - id: laundry_index_text_offset
        type: u4
        doc: Where the text starts (UTF-16BE).
  pollen_count_table:
    doc: Turns a pollen code into text. Only checked on region group 0 consoles (Japan, Taiwan).
    seq:
      - id: pollen_count_code
        type: u1
        doc: The code used by pollen_count in day_block. Must be unique.
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: Padding. Never read.
      - id: pollen_count_text_offset
        type: u4
        doc: Where the text starts (UTF-16BE).
  location_table:
    doc: |
      One city on the globe (0x18 bytes). Every city here must be used by some
      forecast entry, or the channel rejects the file.
    seq:
      - id: key
        type: location_key
        doc: The city's ID.
      - id: city_text_offset
        type: u4
        doc: Where the city name starts (UTF-16BE). Can't be 0.
      - id: region_text_offset
        type: u4
        doc: |
          Where the region name starts (UTF-16BE). 0 means unused. For cities in
          Japan, shown in Japanese, the channel puts this in front of the city name.
      - id: country_text_offset
        type: u4
        doc: Where the country name starts (UTF-16BE). 0 means unused.
      - id: latitude_coordinates
        type: u2
        doc: Where the city sits on the globe.
      - id: longitude_coordinates
        type: u2
        doc: Where the city sits on the globe.
      - id: location_zoom_1
        type: u1
        doc: |
          How important the city is on the globe, 0 to 9. Higher means shown first
          and from further away. 9 is always shown.
      - id: location_zoom_2
        type: u1
        doc: 0 to 3. Checked but nothing uses it. WiiLink always writes 3.
      - id: padding
        type: u2
        doc: Padding. Never read.

enums:
  country_code:
    1: japan
    8: anguilla
    9: antigua_and_barbuda
    10: argentina
    11: aruba
    12: bahamas
    13: barbados
    14: belize
    15: bolivia
    16: brazil
    17: british_virgin_islands
    18: canada
    19: cayman_islands
    20: chile
    21: colombia
    22: costa_rica
    23: dominica
    24: dominican_republic
    25: ecuador
    26: el_salvador
    27: french_guiana
    28: grenada
    29: guadeloupe
    30: guatemala
    31: guyana
    32: haiti
    33: honduras
    34: jamaica
    35: martinique
    36: mexico
    37: monsterrat
    38: netherlands_antilles
    39: nicaragua
    40: panama
    41: paraguay
    42: peru
    43: st_kitts_and_nevis
    44: st_lucia
    45: st_vincent_and_the_grenadines
    46: suriname
    47: trinidad_and_tobago
    48: turks_and_caicos_islands
    49: united_states
    50: uruguay
    51: us_virgin_islands
    52: venezuela
    64: albania
    65: australia
    66: austria
    67: belgium
    68: bosnia_and_herzegovina
    69: botswana
    70: bulgaria
    71: croatia
    72: cyprus
    73: czech_republic
    74: denmark
    75: estonia
    76: finland
    77: france
    78: germany
    79: greece
    80: hungary
    81: iceland
    82: ireland
    83: italy
    84: latvia
    85: lesotho
    86: lichtenstein
    87: lithuania
    88: luxembourg
    89: fyr_of_macedonia
    90: malta
    91: montenegro
    92: mozambique
    93: namibia
    94: netherlands
    95: new_zealand
    96: norway
    97: poland
    98: portugal
    99: romania
    100: russia
    101: serbia
    102: slovakia
    103: slovenia
    104: south_africa
    105: spain
    106: swaziland
    107: sweden
    108: switzerland
    109: turkey
    110: united_kingdom
    111: zambia
    112: zimbabwe
    113: azerbaijan
    114: mauritania
    115: mali
    116: niger
    117: chad
    118: sudan
    119: eritrea
    120: dijibouti
    121: somalia
    128: taiwan
    136: south_korea
    144: hong_kong
    145: macao
    152: indonesia
    153: singapore
    154: thailand
    155: philippines
    156: malaysia
    160: china
    168: uae
    169: india
    170: egypt
    171: oman
    172: qatar
    173: kuwait
    174: saudi_arabia
    175: syria
    176: bahrain
    177: jordan
  language_code:
    0: japanese
    1: english
    2: german
    3: french
    4: spanish
    5: italian
    6: dutch
  wind_direction:
    0: calm
    1: nne
    2: ne
    3: ene
    4: e
    5: ese
    6: se
    7: sse
    8: s
    9: ssw
    10: sw
    11: wsw
    12: w
    13: wnw
    14: nw
    15: nnw
    16: n
    255: unused
  index_code:
    255: unused
  region_flag:
    0: japan
    1: fahrenheit
    2: celsius