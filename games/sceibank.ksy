meta:
  id: sceibank
  title: Sony SCEI sound bank (Momotarou Dentetsu 2010 sound.bin)
  endian: le
doc: |
  File starts "INIT"; every bank is a 0x800 sector starting "BBNK" (BD offset
  u32 @0x1c, 0x2800) or "BANK" (BD offset @0x14, 0x800), followed by "WAVE" and a
  PS2 .hd image at +0x40 ("SCEIVers", "SCEIHead" {u32 chunk size, hd size, bd
  size @0x10}, "SCEIVagi" {u32 chunk size, count, count x u32 entry offsets}).
  Vagi entry {u32 byte offset into the BD, u16 rate, u8 flag, u8 0xff}; BD holds
  PS-ADPCM frames (16 bytes: shift | predictor << 4, flags, 14 data bytes).
seq:
  - id: magic
    contents: INIT
  - id: rest
    size-eos: true
types:
  vagi_entry:
    seq:
      - id: bd_offset
        type: u4
      - id: rate
        type: u2
      - id: flag
        type: u1
      - id: ff
        type: u1
