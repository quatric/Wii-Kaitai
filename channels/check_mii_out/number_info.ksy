meta:
  id: number_info
  title: Check Mii Out Channel - number_info (NI)
  application: Check Mii Out Channel
  file-extension: ces
  endian: be
doc: |
  The Plaza counters file, fetched from /<country>/number_info with list tag
  "NI" (0x4E49). It is 0x30 bytes and carries exactly two numbers.

  These are the values the Plaza shows as "X Miis" and "Y Mii artisans". The
  FD (first/boot) file decides whether they are displayed at all: bit 1 of the
  UI flag bitfield at FD+0x29 is show_mii_artisan_and_contest_mii_count. That
  bit is only a display toggle - the counts themselves live here, never in FD.

  Layout is the standard CMOC list header (see cmoc_header.ksy) followed by one
  sub-record whose payload is the two counters. Wrapped in the usual "MC"
  container: HMAC-SHA1, AES-128-CBC, LZ10.
seq:
  - id: tag
    contents: 'NI'
  - id: flags
    type: u2
    doc: Zero in this file.
  - id: country_region
    type: u4
  - id: list_number
    type: u4
  - id: error_code
    type: u4
    doc: Non-zero makes the channel raise an error dialog.
  - id: reserved
    size: 12
  - id: sentinel
    size: 4
    doc: Always FF FF FF FF.
  - id: sub_tag
    contents: 'NI'
  - id: sub_tag_size
    type: u2
  - id: unknown
    type: u4
    doc: |
      The u4 present at +0x04 of every CMOC sub-record header. WiiLink writes
      0 or 1 and nothing breaks; no branch on it has been found.
  - id: number_of_miis
    type: u4
    doc: |
      Count of Miis in the Posting Plaza. Occupies the slot that carries the
      entry count in every other list file - here there is no entry array, so
      the field is a plain counter.
  - id: number_of_mii_artisans
    type: u4
    doc: Count of registered Mii artisans.
