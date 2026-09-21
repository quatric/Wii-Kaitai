meta:
  id: mkw_wpf
  endian: be
  title: Wiimms Patch File (WPF/XPF)
doc: |
  Wiimms Patch File, per `wpf_head_t`/`wpf_t` in lib-staticr.h. A
  header followed by a stream of variable-length patch/condition
  records terminated by a record with selector 0.
seq:
  - id: magic
    type: u4
    valid:
      any-of: [0x57504601, 0x58504601]
    doc: 0x57504601 = "WPF\x01", 0x58504601 = "XPF\x01".
  - id: version
    type: u4
  - id: size
    type: u4
  - id: records
    type: wpf_record
    repeat: eos
types:
  wpf_record:
    seq:
      - id: selector
        type: u1
        doc: 0 ends the list; bits 0x01-0x08 staticr regions, 0x10-0x80 main.dol regions.
      - id: patch_type
        type: u1
        doc: 0 end, 'P' patch, 'E' equal-condition, 'N' not-equal-condition.
        if: selector != 0
      - id: clear_cond
        type: u1
        doc: 0 nothing, 'C' clear previous condition, 'E' invert condition.
        if: selector != 0
      - id: addr_type
        type: u1
        doc: 0 end, 'A' address, 'O' file offset.
        if: selector != 0
      - id: addr
        type: u4
        if: selector != 0
      - id: data_size
        type: u4
        if: selector != 0
      - id: data
        size: (data_size + 3) & ~3
        if: selector != 0
