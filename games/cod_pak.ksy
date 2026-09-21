meta:
  id: cod_pak
  file-extension: pak
  endian: le
  title: Call of Duty (Black Ops / MW3, Wii) PAK0 sound archive
doc: |
  `PAK0` is the flat sound-bank archive used by the Wii ports of Call of
  Duty: Black Ops and Modern Warfare 3, holding raw `.dsp` (Nintendo ADPCM)
  audio members. Members carry no names in the format at all: each is
  identified purely by a CRC, and this codebase recovers a usable
  filename by formatting that CRC as `<anything>_0x%08x.dsp` on extract.

  All fields are little endian. The header is `PAK0` magic, a u32 `salt`
  whose meaning is not otherwise interpreted (round-tripped byte for
  byte when rebuilding an existing archive), a u32 entry count `n`, a u32
  `multiplier`, and a u32 `data_start`. Immediately after the header
  comes a table of `n` fixed 12-byte entries -- `crc`, `rel_offset`,
  `size` -- where each member's *absolute* file offset is
  `rel_offset * multiplier + data_start` (newly built archives always use
  `multiplier = 1`, i.e. offsets packed contiguously from `data_start`,
  but the multiplier lets a game's original archives use offsets scaled
  by some other block size). `data_start` itself is only required to
  land at or after the end of the entry table.

  Reconstructed from the reader/rebuilder in lib-cod-pak.c
  (`create_cod_pak_dir`, which both re-derives this layout when rebuilding
  from a directory tree and reuses an existing archive's exact layout for
  a byte-identical round trip); there is no standalone parser for
  existing PAK0 files in this codebase, only the writer's own
  layout-validation logic, which this .ksy mirrors for reading.
seq:
  - id: magic
    contents: "PAK0"
  - id: salt
    type: u4
    doc: Opaque value, not otherwise interpreted; preserved byte-for-byte on rebuild.
  - id: num_entries
    type: u4
  - id: multiplier
    type: u4
    doc: Scale factor applied to each entry's `rel_offset` to get an absolute file offset.
  - id: ofs_data_start
    type: u4
    doc: Absolute offset where member payloads begin; also the multiplier's implicit base.
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_entries
types:
  entry:
    seq:
      - id: crc
        type: u4
        doc: CRC identifying this member; the format's only "name".
      - id: rel_offset
        type: u4
        doc: Offset of this member's data, scaled by the header's `multiplier`.
      - id: size
        type: u4
    instances:
      ofs_data:
        value: rel_offset * _root.multiplier + _root.ofs_data_start
      data:
        io: _root._io
        pos: ofs_data
        size: size
