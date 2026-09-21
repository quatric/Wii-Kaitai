meta:
  id: sfx
  endian: le
  title: Monster Games SFX audio (Excite Truck / ExciteBots, Wii)
doc: |
  Monster Games ".sfx" DSP-ADPCM audio, per lib-sfx.c/.h. A fixed
  0x80-byte header (mixed little/big-endian fields, kept as they
  appear on disc) over a plain Nintendo DSP-ADPCM stream.
seq:
  - id: data_size
    type: u4
    doc: Payload bytes after the header; + 0x80 equals the file size exactly.
  - id: header_size
    type: u4
    doc: >-
      Header length, little-endian and required to be exactly 0x80.  The
      reference validator also requires data_size + header_size to equal the
      complete file length.
  - id: unknown_08
    size: 0x10 - 8
    doc: Unused header bytes at 0x08..0x0f; preserve when repacking.
  - id: sample_rate
    type: u4
    doc: Little-endian decoded PCM sample rate in Hz.
  - id: byte_rate
    type: u4
    doc: sample_rate * 2 (decoded audio is 16-bit mono).
  - id: unknown_18
    size: 0x34 - 0x18
    doc: Unused header bytes at 0x18..0x33; preserve when repacking.
  - id: num_nibbles
    type: u4be
    doc: >-
      Big-endian DSP-ADPCM nibble count.  The validator accepts values from
      data_size through data_size * 2 + 16, accommodating the final partial
      frame's padding nibbles.
  - id: unknown_38
    size: 0x3c - 0x38
    doc: Unused header bytes at 0x38..0x3b; preserve when repacking.
  - id: coef
    type: s2be
    repeat: expr
    repeat-expr: 16
  - id: frames
    size: data_size
    doc: >-
      Exactly data_size bytes of DSP-ADPCM frames.  Each full 8-byte frame is
      one predictor/scale byte plus 14 sample nibbles; this size field, not
      end-of-file, defines the payload boundary.
instances:
  decoded_sample_count:
    value: data_size / 8 * 14
    doc: >-
      Decoded mono sample count for complete DSP frames.  This is the value
      nintoolbox supplies to its GENH wrapper; num_nibbles retains any more
      precise partial-final-frame count.
