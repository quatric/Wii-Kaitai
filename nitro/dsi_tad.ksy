meta:
  id: dsi_tad
  title: Nintendo DSi installable title (.tad)
  file-extension: tad
  endian: be
doc: |
  The DSi's installable-title container (TwlSDK `maketad`; installed by
  TDT / TwlNmenu), the DSi's WAD. It uses the same big-endian container as a Wii
  WAD but with the type tag `Is` (`ib` and `Bk` are the Wii variants).

  A 0x20-byte header is followed by the certificate chain, CRL, ticket, TMD,
  content data and footer, each starting on a 0x40 boundary (the last need not
  be padded). Content *i* is stored as AES-128-CBC with IV =
  `{content index as big-endian u2, 14 zero bytes}`, padded to 16; the ticket
  carries the title key wrapped by the DSi common key with IV =
  `{title id, 8 zero bytes}`. The TMD content records hold the plain size and
  SHA-1, which identifies the right common key (retail, debug, or the Wii
  debug key) after the fact. nintoolbox follows WinterMute's twltool.

  nintoolbox validates `tik_size >= 0x1f2` and `tmd_size >= 0x1e4`, and that every
  section lies inside the file.
seq:
  - id: header_size
    type: u4
    valid: 0x20
  - id: type
    contents: 'Is'
  - id: version
    type: u2
  - id: cert_size
    type: u4
  - id: crl_size
    type: u4
  - id: ticket_size
    type: u4
  - id: tmd_size
    type: u4
  - id: data_size
    type: u4
  - id: footer_size
    type: u4
  - id: header_padding
    size: 0x40 - 0x20
  - id: cert_chain
    size: cert_size
  - id: cert_padding
    size: (0x40 - (cert_size % 0x40)) % 0x40
  - id: crl
    size: crl_size
  - id: crl_padding
    size: (0x40 - (crl_size % 0x40)) % 0x40
  - id: ticket
    size: ticket_size
    doc: Signed ticket; carries the wrapped title key.
  - id: ticket_padding
    size: (0x40 - (ticket_size % 0x40)) % 0x40
  - id: tmd
    size: tmd_size
    doc: Signed title metadata; content records hold plain size and SHA-1.
  - id: tmd_padding
    size: (0x40 - (tmd_size % 0x40)) % 0x40
  - id: data
    size: data_size
    doc: Encrypted contents, each padded to 0x40 (AES-CBC, 16-byte padded).
  - id: data_padding
    size: (0x40 - (data_size % 0x40)) % 0x40
  - id: footer
    size: footer_size
