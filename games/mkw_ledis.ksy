meta:
  id: mkw_ledis
  application: Mario Kart Wii
  encoding: UTF-8
doc: |
  LE-DIS / LE-DEF text-based distribution files used by LE-CODE (Wiimms
  SZS Tools, lib-ledis.h / lib-ledis.c). These are line-oriented ASCII/
  UTF-8 text documents -- not fixed binary records -- so this definition
  only pins down the fixed 8-byte magic tag on line 1 that identifies
  the sub-format; the remainder of the file is free-form "KEY=VALUE"
  and comment text, generated with plain fprintf() by the reference
  tool, and is exposed here as an opaque body.

  Known 8-byte magics (see lib-ledis.h):
    "#LE-DEF1" -- LE-CODE track definition (LE_DEFINE_MAGIC8)
    "#LE-DIST" -- LE-CODE track distribution (LE_DISTRIB_MAGIC8)
    "#LE-REF1" -- LE-CODE track reference (LE_REFERENCE_MAGIC8)
    "#LE-STR1" -- LE-CODE track strings (LE_STRINGS_MAGIC8)
    "#SHA1REF" -- SHA1 reference list (LE_SHA1REF_MAGIC8)
    "#SHA1ID1" -- SHA1 id list (LE_SHA1ID_MAGIC8)
    "#PREFIX1" -- prefix table (LE_PREFIX_MAGIC8)
    "#MTCAT03" -- music/track category table (LE_MTCAT_MAGIC8)
    "#CT-SHA1" -- custom-track SHA1 list (LE_CT_SHA1_MAGIC8)
    "#DISTRIB" -- generic distribution info (DISTRIB_MAGIC8)
seq:
  - id: magic
    type: str
    size: 8
    doc: |
      One of the 8-byte magics listed above, e.g. "#LE-DIST". Not
      validated further here since the exact set is open-ended (new
      "#XXXXXXXX"-style tags may appear in newer tool versions).
  - id: body
    type: str
    size-eos: true
    doc: |
      Remaining file content: a free-form text document of
      "@KEY=VALUE" header lines, blank-line-separated records and
      "#"-style comments, as produced by the corresponding
      Dump*() function in lib-ledis.c.
