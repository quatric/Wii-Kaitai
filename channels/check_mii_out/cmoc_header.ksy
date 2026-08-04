meta:
  id: cmoc_header
  application: Check Mii Out Channel
  endian: be
doc: |
  The 0x20-byte header that begins every Check Mii Out Channel list file, followed by
  the first tagged sub-record.

  Historically this block was described three different ways across first.ksy,
  con_info.ksy and mii_list.ksy. They were all looking at the same bytes:

    * first.ksy split 0x04-0x07 into id1 (u1) / id2 (u2) / country_code (u1). Because
      the field is one big-endian u4 and country codes fit in a byte, the low byte lands
      at 0x07 - so "country_code at 0x07" was accidentally right and id1/id2 were the
      zero high bytes.
    * con_info.ksy and mii_list.ksy read 0x04 as a u4 directly, which is what the
      WiiLink24 generator writes. Use that reading.
    * All three called 0x10-0x1F "16 bytes of padding". It is 12 zero bytes followed by
      FF FF FF FF at 0x1C.

  Byte 0x02 is zero in most files; the FD (first/boot) file uses it as a
  service-discontinued flag.

  Three of the list_tag values are category tags rather than record types. The console
  carries membership predicates for them:

    XC (0x5843) "any artisan record" -> XC, PC, RC, CC     (isXC at 0x80079E08)
    XM (0x584D) "any Mii record"     -> XM, PM, IM, CM     (isXM at 0x80079CFC)
    XX (0x5858) "any record"         -> XX, plus all of XM and XC  (isXX at 0x80079C90)

  Call sites test the category, not the concrete tag, which is how one display path
  handles Grab Bag, contest and ranking entries alike. A parser should never expect to
  read XC/XM/XX out of a file.

  Files carrying this header are wrapped in the "MC" container: 2-byte magic "MC",
  a u2 version (both 0x0000 and 0x0001 appear as accepted literals in retail content),
  a 20-byte HMAC-SHA1 over the ciphertext, then AES-128-CBC over LZ10-compressed data.
seq:
  - id: tag
    type: str
    size: 2
    encoding: ascii
    doc: Two-character list tag - FD, SL, RL, NL, CD, CI, CL, PL, IL, TH, NI, IN, OS, SR, LL, ...
  - id: flags
    type: u2
    doc: Zero in most files. In FD, the high byte is the discontinued-service flag.
  - id: country_region
    type: u4
    doc: Country/region group. Overloaded as the contest ID in contest files.
  - id: list_number
    type: u4
    doc: List number, contest ID or craftsno depending on the tag.
  - id: error_code
    type: u4
    doc: Non-zero makes the channel raise an error dialog.
  - id: reserved
    size: 12
  - id: sentinel
    size: 4
    doc: Always FF FF FF FF.
types:
  sub_record_header:
    doc: |
      Every record after the 0x20-byte header starts with this. The first one begins at
      0x20. size is the size of the record's payload as the generator declares it -
      12 for PN, 96 for PM/PC, 24 for IN, and so on.
    seq:
      - id: tag
        type: str
        size: 2
        encoding: ascii
      - id: size
        type: u2
      - id: unknown
        type: u4
        doc: |
          Present in every sub-record. WiiLink writes 0 or 1 and nothing breaks.
          Read by the display code; nothing found so far branches on it.
enums:
  list_tag:
    0x4644: fd_first
    0x534c: sl_spot_list
    0x524c: rl_bargain_list
    0x4e4c: nl_new_list
    0x4344: cd_contest_detail
    0x4349: ci_contest_info
    0x434c: cl_popcrafts_list
    0x504c: pl_popular_list
    0x5243: rc_extended_artisan
    0x524b: rk_ranking_movement
    0x504d: pm_pair_mii
    0x5043: pc_pair_artisan
    0x454c: el_entry_list
    0x434d: cm_contest_mii
    0x424c: bl_best_list
    0x434e: cn_contest
    0x4343: cc_contest_artisan
    0x5448: th_thumbnail
    0x504e: pn_mii_pair_number
    0x494c: il_special_list
    0x4e49: ni_number_info
    0x5048: ph_souvenir
    0x494e: in_artisan_info
    0x494d: im_mii_info
    0x4f53: os_own_search
    0x4e53: ns_name_search
    0x5352: sr_search
    0x4c4c: ll_select_list
    0x4552: er_error
    0x5843: xc_any_artisan
    0x584d: xm_any_mii
    0x5858: xx_any_record
