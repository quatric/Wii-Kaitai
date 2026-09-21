meta:
  id: misc
  file-extension: bin
  endian: be
doc: >-
  Fixed 0x3c38-byte Wii system miscellaneous state record.  It begins with
  three 64-bit timestamp-like values, a 24-byte unrecovered region, and the
  STM wake-up time; the remaining 0x3c00 bytes are retained verbatim because
  their layout has not been recovered.
seq:
  - id: mail_timestamps
    type: u8
    repeat: expr
    repeat-expr: 3
    doc: Three 64-bit timestamp-like values at offsets 0x00, 0x08 and 0x10.
  - id: unknown
    size: 24
    doc: >-
      Unrecovered 24-byte control/timestamp region at offsets 0x18..0x2f;
      preserve it rather than treating it as known-zero padding.
  - id: timestamp_stm
    type: u8
    doc: 64-bit time at which the system requests STM_Wakeup.
  - id: padding
    size: 15360
    doc: >-
      Unrecovered 0x3c00-byte tail at offsets 0x38..0x3c37.  Preserve this
      region when updating the leading timing fields.
