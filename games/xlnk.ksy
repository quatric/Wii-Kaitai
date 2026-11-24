meta:
  id: xlnk
  title: XLink2 effect / sound link database (.belnk / .bslnk)
  endian: le
doc: |
  Header: magic, u32 data size, u32 version, u32 numResParam, numResAssetParam,
  numResTriggerOverwriteParam, ptr triggerOverwriteParamTablePos, ptr
  localPropertyNameRefTablePos, u32 numLocalPropertyNameRef,
  numLocalPropertyEnumNameRef, numDirectValue, numRandom, numCurve,
  numCurvePoint, ptr exRegionPos, u32 numUser, ptr conditionTablePos, ptr
  nameTablePos; then numUser sorted u32 user-name CRC32s and numUser absolute
  user offsets, then the param define table and asset param records. "ptr" is
  u32 on 32-bit layouts and u64 (8-aligned) on 64-bit ones; Wii U files are big
  endian. Versions: 0x1e/0x1c BotW, MK8D, ARMS (32-bit); 0x1f/0x1d ACNH; 0x22/
  0x1f Splatoon 3 (64-bit); 0x24/0x21+ TotK, Wonder (64-bit).
seq:
  - id: magic
    contents: XLNK
  - id: data_size
    type: u4
  - id: version
    type: u4
  - id: rest
    size-eos: true
