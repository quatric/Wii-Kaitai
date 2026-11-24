meta:
  id: sygnus
  title: Sygnus .soundstream (after AES decryption)
  file-extension: soundstream
doc: |
  Kirby Air Riders. AES-192-ECB encrypted files are decrypted first; payload
  at 0x2c is 4-bit ADPCM, Switch Opus or a plain RIFF/WAVE. Header fields are
  not documented in the extractor.
seq:
  - id: header
    size: 0x2c
  - id: payload
    size-eos: true
