meta:
  id: jpi_index
  title: Data East Arcade Classics index (.jpi)
  file-extension: jpi
  endian: le
doc: |
  Data East Arcade Classics (Wii) `index/<name>.jpi`, indexing
  `sound/<name>.jps`, which holds the members back to back. Short members are
  standalone big-endian DSP-ADPCM files. The long music members (loop positions
  set, no DSP header) are headerless signed 8-bit PCM; their rate is assumed,
  not stored. Loop positions are absolute `.jps` byte positions, or 0xFFFFFFFF.
seq:
  - id: table_bytes
    type: u4
  - id: first_id
    type: u4
  - id: entries
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: len_data
        type: u4
      - id: zero0
        type: u4
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: zero1
        type: u8
