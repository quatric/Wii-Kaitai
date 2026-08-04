meta:
  id: conresult
  title: Check Mii Out Channel - conresult.cgi response
  application: Check Mii Out Channel
  file-extension: bin
  endian: be
doc: |
  Response body of `conresult.cgi`, the contest-results endpoint.

  Unlike every static list file this channel downloads, this blob is served as-is:
  it is NOT wrapped in the "MC" container, NOT AES-128-CBC encrypted, NOT LZ10
  compressed, and carries NO HMAC-SHA1 or RSA signature. It is a bare array of
  fixed-size records with no file header.

  Each record is one Mii that was voted on, tagged 'CR' like any other CMOC
  sub-record, so the first four bytes follow the same tag/size shape as
  cmoc_header.ksy's sub_record_header.

  The ranking byte is a percentile rather than a place:

      ranking = round((i / 10) / len(miis) * 90) + 1

  giving 1 for the best entry and 91 for the worst.
seq:
  - id: entries
    type: voted_mii
    repeat: eos
types:
  voted_mii:
    doc-ref: 'record is 0x60 bytes'
    seq:
      - id: tag
        type: str
        size: 2
        encoding: ascii
        doc: Always "CR".
      - id: size
        type: u2
        doc: Record payload size as the generator declares it.
      - id: index
        type: u4
        doc: Entry index within the result set.
      - id: artisan_id
        type: u4
        doc: Craftsno of the Mii's artisan.
      - id: mii_data
        size: 82
        doc: |
          Mii store data followed by padding out to 82 bytes. The Mii itself is
          the usual 74-byte RFL store-data blob plus its u2 CRC16.
      - id: ranking
        type: u1
        doc: |
          Percentile, 1 (best) to 91 (worst). Not a place - two Miis can share
          a value, and the range does not depend on the number of entries.
      - id: padding
        size: 1
