meta:
  id: con_info
  file-extension:
    - ces
    - dec
  application: Check Mii Out Channel
  endian: be
seq:
  - id: header
    type: header
  - id: contest
    type: contest
    repeat: eos
types:
  header:
    seq:
      - id: type
        type: str
        size: 2
        encoding: ascii
      - id: padding1
        size: 2
      - id: country_code
        type: u4
      - id: padding2
        size: 4
      - id: error_code
        type: u4
      - id: padding3
        size: 16
  contest:
    seq:
      - id: type
        type: str
        size: 2
        encoding: ascii
      - id: ci_size
        type: u2
      - id: contest_index
        type: u4
      - id: contest_id
        type: u4
      - id: status
        type: u1
        enum: status
        doc: |
          Bitfield, but common values are: 2=open, 8=judging, 32=results.
          Full bitfield: bit 0 new, bit 1 open, bit 2 preparing_for_judging,
          bit 3 judging, bit 4 preparing_results, bit 5 results, bit 6 cancelled.
      - id: options
        type: u1
        doc: |
          Bitfield: bit 4 special_award, bit 3 nickname_changing,
          bit 2 souvenir_photo, bit 1 thumbnail, bit 0 worldwide.
          Values of 2 or 10 will make it try to grab thumbnails.
      - id: padding
        size: 18
enums:
  status:
    2: open
    8: judging
    32: results