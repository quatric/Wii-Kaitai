meta:
  id: first
  file-extension:
    - dec
  endian: be
doc: |
  Check Mii Out Channel boot/config file, tag "FD".
  Bytes 0x00-0x1F are the common CMOC list header - see cmoc_header.ksy. Earlier
  revisions split 0x04-0x07 into id1/id2/country_code; those are the same bytes as the
  single big-endian u4 that con_info.ksy and mii_list.ksy declare. Because country codes
  fit in a byte, the low byte lands at 0x07, which is why the split happened to put
  country_code on the right byte while hiding the structure.
seq:
  - id: type
    type: str
    size: 2
    encoding: ascii
  - id: discontinued_flag
    type: u1
    doc: Non-zero shows the "service has been discontinued" notice.
  - id: padding0
    size: 1
  - id: country_code
    type: u4
    doc: Common-header country/region field; the low byte is the country code.
  - id: list_number
    type: u4
  - id: error_code
    type: u4
    doc: Non-zero makes the channel raise an error dialog.
  - id: padding2
    size: 12
  - id: padding3
    size: 4
    doc: Always FF FF FF FF.
  - id: tag
    type: str
    size: 2
    encoding: ascii
  - id: tag_size
    type: u2
  - id: unk8
    type: u4
  - id: country_group
    type: u1
  - id: unk5
    type: b3
  - id: enable_scrolling_marquee
    type: b1
  - id: reenable_initials
    type: b1
  - id: disable_initials
    type: b1
  - id: show_mii_artisan_and_contest_mii_count
    type: b1
  - id: show_posting_plaza_mii_count
    type: b1
  - id: unk6
    type: u1
  - id: unk7
    type: b1
  - id: message_service_language_dutch
    type: b1
  - id: message_service_language_italian
    type: b1
  - id: message_service_language_spanish
    type: b1
  - id: message_service_language_french
    type: b1
  - id: message_service_language_german
    type: b1
  - id: message_service_language_english
    type: b1
  - id: message_service_language_japanese
    type: b1
