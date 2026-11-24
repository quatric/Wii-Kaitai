meta:
  id: torquedso
  title: Compiled TorqueScript (.dso)
  file-extension: dso
  endian: le
doc: |
  The Destiny of Zorro and other Torque Game Engine titles. Code stream is
  8-bit opcodes with 8/32-bit operands, not decompiled.
seq:
  - id: version
    type: u4
    doc: 33..36.
  - id: global_strings_size
    type: u4
  - id: global_strings
    size: global_strings_size
    doc: NUL-separated.
  - id: function_strings_size
    type: u4
  - id: function_strings
    size: function_strings_size
  - id: global_float_count
    type: u4
  - id: global_floats
    type: f8
    repeat: expr
    repeat-expr: global_float_count
  - id: function_float_count
    type: u4
  - id: function_floats
    type: f8
    repeat: expr
    repeat-expr: function_float_count
  - id: code_size
    type: u4
  - id: line_break_pair_count
    type: u4
  - id: code
    size-eos: true
