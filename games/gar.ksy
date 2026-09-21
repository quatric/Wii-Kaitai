meta:
  id: gar
  file-extension:
    - gar
    - zar
  endian: le
  title: Grezzo Zelda / Luigi's Mansion 3DS Archive (ZAR/GAR)
doc: |
  Little-endian 3DS archive family used by Grezzo's *Ocarina of Time 3D* /
  *Majora's Mask 3D* (`ZAR\x01`, "queen"/"jenkins" codename) and
  *Luigi's Mansion 3DS* (`GAR`, version 2..5, "agora"/"SYSTEM" codename).
  Ported from nintoolbox's `lib-gar.c` (`ExtractGARArchive`).

  Both variants share a 32-byte header: file group count/offset, file
  count/offset and a data-offset-table offset, plus an 8-byte "codename"
  used here to pick between the two group/file-info record shapes:

  - "SYSTEM" archives ("agora"/"SYSTEM"): each of `file_group_count`
    0x20-byte groups directly holds its file count and a shared extension
    string offset; each of that group's files is a 16-byte record with
    its own size, data offset and name-string offset (data is addressed
    directly, no separate data-offset table).
  - Zelda archives ("queen"/"jenkins"): groups are 16 bytes (just a file
    count), file data offsets live in a separate table at `data_offset`
    (one u32 per file, in file order), and the per-file info record is
    8 bytes (`ZAR\x01`: size + name offset) or 12 bytes (`GAR`: size +
    name offset + filename offset, the reader falls back to the first
    name offset when the second is out of range).
seq:
  - id: magic
    size: 4
    doc: '"ZAR\x01" or "GAR" + version byte (2..5).'
  - id: declared_file_size
    type: u4
  - id: file_group_count
    type: u2
  - id: file_count
    type: u2
  - id: file_group_offset
    type: u4
  - id: file_info_offset
    type: u4
  - id: data_offset
    type: u4
    doc: Absolute offset of the data-offset table (Zelda variant only).
  - id: codename
    type: str
    size: 8
    encoding: ASCII
    doc: '"queen\0\0\0", "jenkins\0", "agora\0\0\0" or "SYSTEM\0\0".'
instances:
  is_system:
    value: 'codename == "agora\0\0\0" or codename == "SYSTEM\0\0"'
