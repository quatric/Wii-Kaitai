meta:
  id: wc24pubk
  file-extension: mod
  application: WiiConnect24
  endian: be
doc: >-
  Fixed 0x220-byte WiiConnect24 public-key module.  WC24 tooling treats bytes
  0x200..0x20f as the embedded AES-128 key; the preceding 0x200 bytes retain
  public-key material whose internal split is not fully recovered.
seq:
  - id: rsa_public
    size: 256
    doc: >-
      The first 0x100 bytes of the 0x220-byte WC24 key module.  It is the
      public-key material supplied with the module, retained verbatim here:
      consumers that need to verify WC24 signatures must interpret it using
      Nintendo's RSA-key convention rather than treating it as text.
  - id: rsa_reserved
    size: 256
    doc: >-
      The remaining 0x100 bytes of the public-key area.  No nintoolbox WC24
      operation consumes this range, and its precise internal subdivision
      (for example, exponent or key metadata) has not been established.  It
      is deliberately modeled as bytes instead of being guessed as padding.
  - id: aes_key
    size: 16
    doc: >-
      AES-128 key used by the WiiConnect24 encrypted-message containers.
      This begins at absolute offset 0x200.  nintoolbox accepts a 544-byte
      wc24pubk.mod blob as a key source and extracts exactly bytes
      [0x200, 0x210) for AES-128-OFB decryption.
  - id: aes_reserved
    size: 16
    doc: >-
      Trailing bytes at offsets 0x210..0x21f.  They complete the fixed
      544-byte module, but are not part of the AES key and are not consumed
      by nintoolbox's WC24 encrypt/decrypt implementation.  Preserve them
      when copying or repacking a module.
