meta:
  id: dhcp
  file-extension: dat
  application: Wii Menu
  endian: be
doc: >-
  Fixed 0x5c-byte Wii Menu DHCP state record.  It stores five 4-octet
  network-address slots separated by preserved unknown regions.  The known
  layout gives no reliable names for the last two address slots or the
  intervening words, so this definition records their offsets without
  pretending they are padding or validated DHCP lease fields.
seq:
  - id: connection_1_ip
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Four raw address octets at offsets 0x00..0x03 for connection slot 1.
  - id: connection_2_ip
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Four raw address octets at offsets 0x04..0x07 for connection slot 2.
  - id: connection_3_ip
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Four raw address octets at offsets 0x08..0x0b for connection slot 3.
  - id: padding
    size: 20
    doc: >-
      Unrecovered 20-byte region at offsets 0x0c..0x1f.  Preserve it; it is
      not known to be all-zero padding.
  - id: ip_4
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Fourth four-octet address-like slot at offsets 0x20..0x23.
  - id: padding2
    type: u4
    doc: Unrecovered big-endian word at offsets 0x24..0x27.
  - id: ip_5
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Fifth four-octet address-like slot at offsets 0x28..0x2b.
  - id: padding3
    size: 48
    doc: >-
      Unrecovered tail at offsets 0x2c..0x5b.  Retain byte-for-byte when
      editing the address slots.
