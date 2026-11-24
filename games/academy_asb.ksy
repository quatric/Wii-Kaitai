meta:
  id: academy_asb
  title: Academy of Champions sound package (.asb)
  file-extension: asb
  endian: be
doc: |
  Academy of Champions: Soccer (Wii) `WII/Sounds/_Packages/*.asb` (not the
  Nintendo animation `ASB `). A flat stream of chunks: `ftyp`, `fcnt`, then per
  sound `snd `, `path`, `stor` (`MEMORY`), `fmt ` (`GCADPCM`), `rate`, `chan`
  and `data`. A GCADPCM payload is a variably zero-padded standard DSP header
  followed by the ADPCM frames.
seq:
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ASCII
      - id: len_payload
        type: u4
      - id: payload
        size: len_payload
