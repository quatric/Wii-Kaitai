meta:
  id: chnktree
  title: CHNK tree file (Tierpension / Paws & Claws engine)
  endian: be
doc: |
  Used for .scene, .object, .phn, .var, .cha. "CHNK" then one root chunk;
  every chunk = {tag[4], u32 size (whole chunk incl. this 8-byte header),
  payload}. A chunk is a container when its payload (optionally after one u32
  count/flag word) is an exact sequence of valid chunks, optionally followed
  by a 4-byte terminator equal to the parent tag.
seq:
  - id: magic
    contents: CHNK
  - id: root
    type: chunk
types:
  chunk:
    seq:
      - id: tag
        size: 4
        type: str
        encoding: ASCII
      - id: size
        type: u4
      - id: payload
        size: size - 8
