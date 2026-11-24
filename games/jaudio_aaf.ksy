meta:
  id: jaudio_aaf
  title: Nintendo JAudio v1 AAF archive (.aaf)
  file-extension: aaf
  endian: be
doc: |
  Super Mario Sunshine, Luigi's Mansion, Wind Waker, Pikmin 2. A list of chunk
  ids each followed by payload words: 1/4/6/7 {offset, size, flags}, 5 {offset,
  size, flags} (stream table), and 2 (IBNK) / 3 (WSYS) a run of {offset, size,
  id} entries ended by a zero offset; the id list ends with 0.
seq:
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _.id == 0
types:
  chunk:
    seq:
      - id: id
        type: u4
      - id: body
        type:
          switch-on: id
          cases:
            1: triple
            4: triple
            5: triple
            6: triple
            7: triple
            2: entry_run
            3: entry_run
  triple:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: flags
        type: u4
  entry_run:
    seq:
      - id: entries
        type: entry
        repeat: until
        repeat-until: _.offset == 0
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
        if: offset != 0
      - id: id
        type: u4
        if: offset != 0
