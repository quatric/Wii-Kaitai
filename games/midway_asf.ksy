meta:
  id: midway_asf
  title: Midway streaming bank (.ASF)
  file-extension: asf
  endian: le
doc: |
  Midway streaming bank (TNA Impact! COMMSTRM/FEMUSIC/...; mixed endian: the
  16-byte descriptors are little endian, the embedded DSP headers big endian).
  Entry k's descriptor is at `0x70 * k`, the 4-character track tag (`MTYT`,
  `MTYU`, `M_01`, ...) at `0x70 * k + 0x10`, together with a standard 0x60-byte
  GameCube DSP-ADPCM header. Each entry's mono ADPCM data sits at its absolute
  audio offset. The count is only present in the first descriptor.
seq:
  - id: first_descriptor
    type: descriptor
types:
  descriptor:
    seq:
      - id: count_first_only
        type: u4
      - id: audio_offset
        type: u4
      - id: len_audio
        type: u4
      - id: flags
        type: u4
        doc: 0x0201.
