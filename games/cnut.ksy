meta:
  id: cnut
  file-extension: cnut
  endian: be
  title: Compiled Squirrel script (Wii Party CNUT/SQIR)
doc: |
  A compiled Squirrel scripting-language bytecode file (`.cnut`/`.nut`),
  seen in Wii Party and other Nd Cube games. Everything is big endian.

  The file opens with a 10-byte header: a `0xFAFA` stream tag, the
  4-byte magic `SQIR`, and a u32 `char_size` (Squirrel's `SQChar` size,
  always seen as 1). What follows is a single recursively-nested
  function prototype (the script's top-level "main" function, whose
  nested closures are themselves function prototypes).

  A function prototype is a sequence of ten sections, each preceded by a
  4-byte `PART` tag (used purely as a structural marker, not a length):
  source name, function name (each a Squirrel "object"), a 32-byte block
  of eight section counts, the literals table, parameter names, outer
  (upvalue) values, local variables, line-number info, default parameter
  values, instructions, and nested child function prototypes -- followed
  by 6 bytes of metadata (stack size, generator flag, varargs flag).

  A Squirrel "object" is a tagged value: a u32 raw type tag (whose low
  16 bits select `SQ_RT_STRING`/`SQ_RT_INTEGER`/`SQ_RT_FLOAT`/
  `SQ_RT_BOOL`/`SQ_RT_NULL`, the only tags this format emits) followed by
  a type-dependent payload -- a u32 length + that many bytes for a
  string, or a plain u32 for the others (absent for null). Instructions
  are fixed 8-byte records: a s32 `arg1` followed by four bytes
  `op`/`arg0`/`arg2`/`arg3` (opcode byte plus three operand bytes).

  Reconstructed from the reader/writer in lib-cnut.c (`ScanCNUT`/
  `parse_proto`/`CreateCNUT`); `IsCNUT()` only checks the stream tag and
  magic, so this .ksy verifies the same two fields.
seq:
  - id: stream_tag
    contents: [0xfa, 0xfa]
  - id: magic
    contents: "SQIR"
  - id: char_size
    type: u4
    doc: Size of Squirrel's SQChar type in bytes; always seen as 1.
  - id: root
    type: func_proto
    doc: The script's top-level function prototype.
types:
  sq_object:
    seq:
      - id: raw_type
        type: u4
        enum: sq_type
      - id: value
        type:
          switch-on: raw_type
          cases:
            'sq_type::string': sq_string
            'sq_type::integer': s4
            'sq_type::float_val': u4
            'sq_type::bool_val': u4
            _: empty
  sq_string:
    seq:
      - id: len
        type: u4
      - id: text
        size: len
        type: str
        encoding: ASCII
  empty:
    doc: Placeholder for object types with no payload (e.g. null).
    seq: []
  part_tag:
    doc: Structural section marker; not a length, just literally the bytes "PART".
    seq:
      - id: magic
        contents: "PART"
  count_block:
    seq:
      - id: n_literals
        type: u4
      - id: n_parameters
        type: u4
      - id: n_outervalues
        type: u4
      - id: n_localvars
        type: u4
      - id: n_lineinfos
        type: u4
      - id: n_defaultparams
        type: u4
      - id: n_instructions
        type: u4
      - id: n_functions
        type: u4
  outer_value:
    seq:
      - id: type
        type: u4
      - id: src
        type: sq_object
      - id: name
        type: sq_object
  local_var:
    seq:
      - id: name
        type: sq_object
      - id: pos
        type: u4
      - id: start_op
        type: u4
      - id: end_op
        type: u4
  line_info:
    seq:
      - id: line
        type: u4
      - id: op
        type: u4
  instruction:
    seq:
      - id: arg1
        type: s4
      - id: op
        type: u1
        enum: opcode
      - id: arg0
        type: u1
      - id: arg2
        type: u1
      - id: arg3
        type: u1
  func_proto:
    seq:
      - id: part_1
        type: part_tag
      - id: source_name
        type: sq_object
      - id: func_name
        type: sq_object
      - id: part_2
        type: part_tag
      - id: counts
        type: count_block
      - id: part_3
        type: part_tag
      - id: literals
        type: sq_object
        repeat: expr
        repeat-expr: counts.n_literals
      - id: part_4
        type: part_tag
      - id: parameters
        type: sq_object
        repeat: expr
        repeat-expr: counts.n_parameters
      - id: part_5
        type: part_tag
      - id: outervalues
        type: outer_value
        repeat: expr
        repeat-expr: counts.n_outervalues
      - id: part_6
        type: part_tag
      - id: localvars
        type: local_var
        repeat: expr
        repeat-expr: counts.n_localvars
      - id: part_7
        type: part_tag
      - id: lineinfos
        type: line_info
        repeat: expr
        repeat-expr: counts.n_lineinfos
      - id: part_8
        type: part_tag
      - id: defaultparams
        type: u4
        repeat: expr
        repeat-expr: counts.n_defaultparams
      - id: part_9
        type: part_tag
      - id: instructions
        type: instruction
        repeat: expr
        repeat-expr: counts.n_instructions
      - id: part_10
        type: part_tag
      - id: functions
        type: func_proto
        repeat: expr
        repeat-expr: counts.n_functions
      - id: stacksize
        type: u4
      - id: bgenerator
        type: u1
      - id: varparams
        type: u1
enums:
  sq_type:
    0x0001: null_val
    0x0002: integer
    0x0004: float_val
    0x0008: bool_val
    0x0010: string
    0x0020: table
    0x0040: array
    0x0080: userdata
    0x0100: closure
    0x0200: natclosure
    0x0400: generator
    0x0800: userpointer
    0x1000: thread
    0x2000: funcproto
    0x4000: class
    0x8000: instance
  opcode:
    0: line
    1: load
    2: loadint
    3: loadfloat
    4: dload
    5: tailcall
    6: call
    7: prepcall
    8: prepcallk
    9: getk
    10: move
    11: newslot
    12: delete
    13: set
    14: get
    15: eq
    16: ne
    17: arith
    18: bitw
    19: return
    20: loadnulls
    21: loadroottable
    22: loadbool
    23: dmove
    24: jmp
    25: jcmp
    26: jz
    27: setouter
    28: getouter
    29: newobj
    30: appendarray
    31: comparith
    32: inc
    33: incl
    34: pinc
    35: pincl
    36: cmp
    37: exists
    38: instanceof
    39: and
    40: or
    41: neg
    42: not
    43: bwnot
    44: closure
    45: yield
    46: resume
    47: foreach
    48: postforeach
    49: clone
    50: typeof
    51: pushtrap
    52: poptrap
    53: throw
    54: newslota
    55: getbase
    56: close
