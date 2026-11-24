meta:
  id: bobmp3
  title: Are You Smarter than a 5th Grader? .bob voice clip
  file-extension: bob
doc: NUL-terminated caption, NUL-terminated lip-sync string, then a plain MPEG layer III stream.
seq:
  - id: caption
    type: strz
    encoding: UTF-8
  - id: lip_sync
    type: strz
    encoding: ASCII
  - id: mp3
    size-eos: true
