meta:
  id: forecast_file
  file-extension: bin
  application: Forecast Channel
  endian: be
  doc: |
    forecast.bin - 0x58-byte header, then seven independently located tables.

    Nintendo's own names for the tables, recovered from the validator string pool in
    the retail binary (0x80199D10 onward) where they appear in header-field order:
      message_offset          -> ERROR_MESSAGE_e
      long_forecast_table     -> WeatherForecasts  (cities in the console's own country)
      short_forecast_table    -> WeatherSummary    (cities elsewhere)
      weather_condition_codes -> WeatherType
      uv_index_table          -> UVIndex
      laundry_index_table     -> LaundryIndex
      pollen_count_table      -> PollenIndex
      location_table          -> Places

    WARNING: short_forecast_table is the international SUMMARY list inside THIS file.
    It is not short.bin, which is a separate file whose table Nintendo calls WeatherNow
    (see forecast_file_short.ksy). Conflating the two - usually by noticing that the
    summary entry is 0x48 bytes and assuming that is short.bin's stride - is the most
    common error in third-party documentation of this format.

    Laundry and pollen indices are only validated when the console's region word
    (r13-0x6A04) is zero, i.e. on Japanese consoles.

seq:
  - id: version
    type: u4
    doc: Always 0.
  - id: filesize
    type: u4
  - id: crc32
    type: u4
  - id: opening_timestamp
    type: u4
    doc: Timestamp is minutes since 2000.
  - id: closing_timestamp
    type: u4
    doc: Timestamp is minutes since 2000.
  - id: country_code
    type: u1
    enum: country_code
  - id: unknown_1
    type: u1
    repeat: expr
    repeat-expr: 3
    doc: |
      Confirmed unread: `FUN_8000c734` (0x8000c734) touches header byte offsets 0x19
      (`region_flag`, ≤2) and 0x1A (`unknown_2`, ≤1) but never this range in between.
      Genuine padding between `country_code` and `language_code`.
  - id: language_code
    type: u1
    enum: language_code
  - id: region_flag
    type: u1
    enum: region_flag
  - id: unknown_2
    type: u1
    doc: |
      Validated at 0x8000C9C8 as `<= 1` (boolean). Validated but never acted on -
      searching every direct-displacement byte load of this offset across the binary
      finds only the bounds check, no consumer. WiiLink writes 1; 0 is equally legal.
  - id: padding
    type: u1
  - id: message_offset
    type: u4
    doc: If this is set, it will display a message at start.
  - id: long_forecast_entry_number
    type: u4
  - id: long_forecast_table_offset
    type: u4
  - id: short_forecast_entry_number
    type: u4
  - id: short_forecast_table_offset
    type: u4
  - id: weather_condition_codes_entry_number
    type: u4
  - id: weather_condition_codes_table_offset
    type: u4
  - id: uv_index_entry_number
    type: u4
  - id: uv_index_table_offset
    type: u4
  - id: laundry_index_entry_number
    type: u4
  - id: laundry_index_table_offset
    type: u4
  - id: pollen_count_entry_number
    type: u4
  - id: pollen_count_table_offset
    type: u4
  - id: location_entry_number
    type: u4
  - id: location_table_offset
    type: u4
instances:
  long_forecast_table:
    pos: long_forecast_table_offset
    type: long_forecast_table
    repeat: expr
    repeat-expr: long_forecast_entry_number
  short_forecast_table:
    pos: short_forecast_table_offset
    type: short_forecast_table
    repeat: expr
    repeat-expr: short_forecast_entry_number
  weather_condition_codes_table:
    pos: weather_condition_codes_table_offset
    type: weather_condition_codes_table
    repeat: expr
    repeat-expr: weather_condition_codes_entry_number
  uv_index_table:
    pos: uv_index_table_offset
    type: uv_index_table
    repeat: expr
    repeat-expr: uv_index_entry_number
  laundry_index_table:
    pos: laundry_index_table_offset
    type: laundry_index_table
    repeat: expr
    repeat-expr: laundry_index_entry_number
  pollen_country_table:
    pos: pollen_count_table_offset
    type: pollen_count_table
    repeat: expr
    repeat-expr: pollen_count_entry_number
  location_table:
    pos: location_table_offset
    type: location_table
    repeat: expr
    repeat-expr: location_entry_number
types:
  long_forecast_table:
    seq:
      - id: country_code
        type: u1
        enum: country_code
      - id: region_code
        type: u1
      - id: location_code
        type: u2
      - id: local_timestamp
        type: u4
        doc: Timestamp is minutes since 2000.
      - id: global_timestamp
        type: u4
        doc: Timestamp is minutes since 2000.
      - id: timezone_tag
        type: u1
        doc: |
          Validated as `<= 5, or exactly 0xFF` (0x8000cb00), one byte via `lbz` -
          NOT the u32 generators often declare here. Never read anywhere else, so
          it has no visible effect on the displayed forecast; its only consumer is
          outside this title.

          Nintendo's retail values: 1 for most cities, 5 for a few (Evansville,
          Gary, Bowling Green, El Paso), 4 for others (Brasília, Nuuk, Palikir),
          0xFF (sentinel) throughout on Japanese files. Best guess is a timezone
          marker - Nuuk shares Denmark's country code but its own zone
          ([ForecastChannel#5](https://github.com/WiiLink24/ForecastChannel/issues/5)).

          Same field, same rule, at short_forecast_table's +0x0C.
      - id: timezone_tag_reserved
        size: 3
        doc: Unread padding after `timezone_tag`; a u32 write here misses the byte actually checked.
      - id: today_forecast
        type: u2
      - id: today_6_hour_forecast_12am_6am
        type: u2
      - id: today_6_hour_forecast_6am_12pm
        type: u2
      - id: today_6_hour_forecast_12pm_6pm
        type: u2
      - id: today_6_hour_forecast_6pm_12am
        type: u2
      - id: today_high_temperature_celsius
        type: s1
      - id: today_high_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_low_temperature_celsius
        type: s1
      - id: today_low_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_high_temperature_fahrenheit
        type: s1
      - id: today_high_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_low_temperature_fahrenheit
        type: s1
      - id: today_low_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_12am_6am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_6am_12pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_12pm_6pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_6pm_12am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_wind_direction
        type: u1
        enum: wind_direction
      - id: today_wind_speed_kilometers_per_hour
        type: u1
      - id: today_wind_speed_miles_per_hour
        type: u1
      - id: today_uv_index
        type: u1
      - id: today_laundry_index
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_pollen_count
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_forecast
        type: u2
      - id: tomorrow_6_hour_forecast_12am_6am
        type: u2
      - id: tomorrow_6_hour_forecast_6am_12pm
        type: u2
      - id: tomorrow_6_hour_forecast_12pm_6pm
        type: u2
      - id: tomorrow_6_hour_forecast_6pm_12am
        type: u2
      - id: tomorrow_high_temperature_celsius
        type: s1
      - id: tomorrow_high_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_low_temperature_celsius
        type: s1
      - id: tomorrow_low_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_high_temperature_fahrenheit
        type: s1
      - id: tomorrow_high_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_low_temperature_fahrenheit
        type: s1
      - id: tomorrow_low_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_12am_6am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_6am_12pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_12pm_6pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_6pm_12am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_wind_direction
        type: u1
        enum: wind_direction
      - id: tomorrow_wind_speed_kilometers_per_hour
        type: u1
      - id: tomorrow_wind_speed_miles_per_hour
        type: u1
      - id: tomorrow_uv_index
        type: u1
        doc: Unused.
      - id: tomorrow_laundry_index
        type: u1
        doc: Only used for the Japanese version of this Channel. Unused.
      - id: tomorrow_pollen_count
        type: u1
        doc: Only used for the Japanese version of this Channel. Unused.
      - id: five_day_forecast_day_1
        type: u2
      - id: five_day_forecast_day_1_temperature_celsius_high
        type: s1
      - id: five_day_forecast_day_1_temperature_celsius_low
        type: s1
      - id: five_day_forecast_day_1_temperature_fahrenheit_high
        type: s1
      - id: five_day_forecast_day_1_temperature_fahrenheit_low
        type: s1
      - id: five_day_forecast_day_1_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_1_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_2
        type: u2
      - id: five_day_forecast_day_2_temperature_celsius_high
        type: s1
      - id: five_day_forecast_day_2_temperature_celsius_low
        type: s1
      - id: five_day_forecast_day_2_temperature_fahrenheit_high
        type: s1
      - id: five_day_forecast_day_2_temperature_fahrenheit_low
        type: s1
      - id: five_day_forecast_day_2_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_2_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_3
        type: u2
      - id: five_day_forecast_day_3_temperature_celsius_high
        type: s1
      - id: five_day_forecast_day_3_temperature_celsius_low
        type: s1
      - id: five_day_forecast_day_3_temperature_fahrenheit_high
        type: s1
      - id: five_day_forecast_day_3_temperature_fahrenheit_low
        type: s1
      - id: five_day_forecast_day_3_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_3_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_4
        type: u2
      - id: five_day_forecast_day_4_temperature_celsius_high
        type: s1
      - id: five_day_forecast_day_4_temperature_celsius_low
        type: s1
      - id: five_day_forecast_day_4_temperature_fahrenheit_high
        type: s1
      - id: five_day_forecast_day_4_temperature_fahrenheit_low
        type: s1
      - id: five_day_forecast_day_4_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_4_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_5
        type: u2
      - id: five_day_forecast_day_5_temperature_celsius_high
        type: s1
      - id: five_day_forecast_day_5_temperature_celsius_low
        type: s1
      - id: five_day_forecast_day_5_temperature_fahrenheit_high
        type: s1
      - id: five_day_forecast_day_5_temperature_fahrenheit_low
        type: s1
      - id: five_day_forecast_day_5_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_5_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_6
        type: u2
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_6_temperature_celsius_high
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_6_temperature_celsius_low
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_6_temperature_fahrenheit_high
        type: s1
        doc: Only used for the Japanese version of this Channel
      - id: five_day_forecast_day_6_temperature_fahrenheit_low
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_6_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_6_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
      - id: five_day_forecast_day_7
        type: u2
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_temperature_celsius_high
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_temperature_celsius_low
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_temperature_fahrenheit_high
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_temperature_fahrenheit_low
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_precipitation
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: five_day_forecast_day_7_padding
        type: u1
        doc: Never validated, never read anywhere in the binary. Genuine padding.
  short_forecast_table:
    seq:
      - id: country_code
        type: u1
        enum: country_code
      - id: region_code
        type: u1
      - id: location_code
        type: u2
      - id: local_timestamp
        type: u4
        doc: Timestamp is minutes since 2000.
      - id: global_timestamp
        type: u4
        doc: Timestamp is minutes since 2000.
      - id: timezone_tag
        type: u1
        doc: |
          Same field and rule as `long_forecast_table`'s `timezone_tag`:
          validated at 0x8000cbe8 as `<= 5, or exactly 0xFF`, one byte, read
          nowhere else.
      - id: timezone_tag_reserved
        size: 3
      - id: today_forecast
        type: u2
      - id: today_6_hour_forecast_12am_6am
        type: u2
      - id: today_6_hour_forecast_6am_12pm
        type: u2
      - id: today_6_hour_forecast_12pm_6pm
        type: u2
      - id: today_6_hour_forecast_6pm_12am
        type: u2
      - id: today_high_temperature_celsius
        type: s1
      - id: today_high_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_low_temperature_celsius
        type: s1
      - id: today_low_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_high_temperature_fahrenheit
        type: s1
      - id: today_high_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_low_temperature_fahrenheit
        type: s1
      - id: today_low_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_12am_6am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_6am_12pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_12pm_6pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_6_hour_precipitation_6pm_12am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: today_wind_direction
        type: u1
        enum: wind_direction
      - id: today_wind_speed_kilometers_per_hour
        type: u1
      - id: today_wind_speed_miles_per_hour
        type: u1
      - id: today_uv_index
        type: u1
        doc: |
          Not simple padding: `FUN_8000d1ec` (0x8000d1ec) validates it exactly like
          `long_forecast_table`'s `today_uv_index` - must be `0xFF` or exist in
          `uv_index_table`. Never displayed by this title; short_forecast_table
          entries (international summary cities) don't get a UV row.
      - id: today_laundry_index
        type: u1
        doc: |
          Same validator, Japan-only branch: checked against `laundry_index_table`
          only when the console region is Japan, exactly like the long table's
          `today_laundry_index`. Unused in the short-entry display path.
      - id: today_pollen_count
        type: u1
        doc: |
          Same validator, Japan-only branch: checked against `pollen_count_table`
          only when the console region is Japan, exactly like the long table's
          `today_pollen_count`. Unused in the short-entry display path.
      - id: tomorrow_forecast
        type: u2
      - id: tomorrow_6_hour_forecast_12am_6am
        type: u2
      - id: tomorrow_6_hour_forecast_6am_12pm
        type: u2
      - id: tomorrow_6_hour_forecast_12pm_6pm
        type: u2
      - id: tomorrow_6_hour_forecast_6pm_12am
        type: u2
      - id: tomorrow_high_temperature_celsius
        type: s1
      - id: tomorrow_high_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_low_temperature_celsius
        type: s1
      - id: tomorrow_low_temperature_celsius_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_high_temperature_fahrenheit
        type: s1
      - id: tomorrow_high_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_low_temperature_fahrenheit
        type: s1
      - id: tomorrow_low_temperature_fahrenheit_difference
        type: s1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_12am_6am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_6am_12pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_12pm_6pm
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_6_hour_precipitation_6pm_12am
        type: u1
        doc: Only used for the Japanese version of this Channel.
      - id: tomorrow_wind_direction
        type: u1
        enum: wind_direction
      - id: tomorrow_wind_speed_kilometers_per_hour
        type: u1
      - id: tomorrow_wind_speed_miles_per_hour
        type: u1
      - id: tomorrow_uv_index
        type: u1
        doc: |
          Was misnamed `today_uv_index` - it sits right after
          `tomorrow_wind_speed_miles_per_hour`, in the *tomorrow* 0x1C-byte block that
          `FUN_8000d1ec` validates on its second pass over this entry (0x8000d1ec).
          Same rule as `today_uv_index` above: `0xFF` or exists in `uv_index_table`.
      - id: tomorrow_laundry_index
        type: u1
        doc: Was misnamed `today_laundry_index`; tomorrow-block equivalent of `today_laundry_index`, Japan-only.
      - id: tomorrow_pollen_count
        type: u1
        doc: Was misnamed `today_pollen_count`; tomorrow-block equivalent of `today_pollen_count`, Japan-only.
  weather_condition_codes_table:
    seq:
      - id: weather_icon_code_1
        type: u2
      - id: weather_icon_code_2
        type: u2
      - id: weather_text_offset
        type: u4
  uv_index_table:
    seq:
      - id: uv_index_code
        type: u1
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: |
          Confirmed unread: the entry-dedup loop in `FUN_8000c734` (0x8000c734) only
          compares `uv_index_code` and range/parity-checks `uv_index_text_offset`;
          these 3 bytes are never touched. Alignment before the u4 offset.
      - id: uv_index_text_offset
        type: u4
  laundry_index_table:
    seq:
      - id: laundry_index_code
        type: u1
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: Confirmed unread by the same validator loop as `uv_index_table`'s equivalent field; alignment only.
      - id: laundry_index_text_offset
        type: u4
  pollen_count_table:
    seq:
      - id: pollen_count_code
        type: u1
      - id: padding
        type: u1
        repeat: expr
        repeat-expr: 3
        doc: Confirmed unread by the same validator loop as `uv_index_table`'s equivalent field; alignment only.
      - id: pollen_count_text_offset
        type: u4
  location_table:
    seq:
      - id: country_code
        type: u1
        enum: country_code
      - id: region_code
        type: u1
      - id: location_code
        type: u2
      - id: city_text_offset
        type: u4
      - id: region_text_offset
        type: u4
      - id: country_text_offset
        type: u4
      - id: latitude_coordinates
        type: u2
      - id: longitude_coordinates
        type: u2
      - id: location_zoom_1
        type: u1
        doc: |
          Marker prominence rank, 0 (least prominent) to 9. Validated as <= 9 at
          0x8000CFFC; a larger value rejects the whole file.

          This is the only one of the two zoom fields the channel consumes. The
          globe scene buckets every city by this value into an array of ten
          linked-list heads at scene+0x3C..+0x60 (0x8001A4C8: `lbz r0, 0x280(r4)`
          then `slwi r0, r0, 2`, indexing scene+0x3C). The currently selected
          city bypasses the buckets entirely and goes in its own slot at
          scene+0x64, immediately after the ten.

          Direction: HIGHER is more prominent. The visibility predicate at
          0x8001AE10 compares two cities' ranks and returns "visible" only when
          the candidate's rank is the greater one; and the selected city is
          forced to 9, the maximum, at 0x800076FC. A rank of 9 therefore means
          "always shown", 0 means "shown last".
      - id: location_zoom_2
        type: u1
        doc: |
          Validated as <= 3 at 0x8000D00C - a different and much smaller range
          than location_zoom_1, which is the reliable way to tell the two apart.

          No consumer for this field was found anywhere in the retail binary;
          only the bounds check reads it. WiiLink's generator pins it to 3, its
          maximum, for all 4,272 cities it emits.
      - id: padding
        type: u2
        doc: |
          Confirmed unread: the location-table validator in `FUN_8000c734`
          (0x8000c734) stops at `location_zoom_2` (byte offset 0x15 of the entry);
          this trailing u2 is never loaded. Pure alignment to the 0x18-byte stride.
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
    0: none
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
  region_flag:
    0: japan
    1: fahrenheit
    2: celsius