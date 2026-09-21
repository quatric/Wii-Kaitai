meta:
  id: bnsh
  file-extension: bnsh
  endian: le
  title: Nintendo Switch Binary Shader (BNSH)
doc: |
  A compiled/source shader container used on the Switch, also embedded
  inside other NX containers. One BNSH holds a table of shader
  "variations", each pointing at one or two `ShaderProgram` records that
  in turn point at per-stage (vertex/tess-control/tess-eval/geometry/
  fragment/compute) code blobs -- either raw compiled machine code,
  zlib-compressed code, or GLSL-NX source text.

  Layout taken from lib-bnsh.c/.h's header comment, itself cross-checked
  against Switch-Toolbox `File_Format_Library/FileFormats/Shader/BNSH.cs`
  and KillzXGaming's `BinaryShaderLibrary`. Two producer conventions exist
  for reaching a variation's `ShaderProgram`: Switch-Toolbox sums
  `source_program_offset + shader_program_offset` to one record,
  BinaryShaderLibrary loads them as two independent programs. Both are
  exposed here (`source_program`/`binary_program`) rather than picked for
  the caller.
seq:
  - id: magic
    contents: "BNSH"
  - id: padding
    type: u4
  - id: version
    type: u4
    doc: Byte-packed major.major2.minor.minor2.
  - id: bom
    type: u2
  - id: alignment
    type: u1
  - id: target
    type: u1
  - id: ofs_filename
    type: u4
    doc: Offset of a u32-length-prefixed string.
  - id: ofs_path
    type: u4
  - id: ofs_reloc_table
    type: u4
  - id: len_file
    type: u4
  - id: reserved
    size: 0x60 - 0x1c
    doc: Padding up to the fixed absolute offset 0x60 where `grsc_magic` begins.
  - id: grsc_magic
    contents: "grsc"
  - id: ofs_block
    type: u4
  - id: len_block
    type: u8
  - id: reserved2
    size: 12
  - id: num_variations
    type: u4
  - id: ofs_variations
    type: u4
    doc: Absolute file offset of the variation table.
instances:
  variations:
    pos: ofs_variations
    type: variation
    repeat: expr
    repeat-expr: num_variations
types:
  variation:
    seq:
      - id: ofs_source_program
        type: s8
      - id: unk2
        type: s8
      - id: ofs_shader_program
        type: s8
      - id: ofs_grsc
        type: s8
        doc: Back-pointer to the owning `grsc` block.
      - id: reserved
        size: 32
    instances:
      source_program:
        pos: ofs_source_program
        type: shader_program
        if: ofs_source_program != 0
      binary_program:
        pos: ofs_shader_program
        type: shader_program
        if: ofs_shader_program != 0
      summed_program:
        pos: ofs_source_program + ofs_shader_program
        type: shader_program
        if: ofs_source_program == 0 or ofs_shader_program == 0
        doc: |
          Switch-Toolbox's convention: a single `ShaderProgram` at the sum
          of the two base offsets, used when the two-independent-program
          layout does not apply.
  shader_program:
    seq:
      - id: kind
        type: u1
        doc: BinaryShaderLibrary `ShaderInfoData.Type`.
      - id: format
        type: u1
        doc: '0 = compiled binary, 3 = source text (`ShaderSourceData`).'
      - id: reserved
        type: u2
      - id: compression
        type: u4
        enum: compression_type
      - id: ofs_stage
        type: s8
        repeat: expr
        repeat-expr: 6
        doc: |
          Absolute offset per stage (vertex, tess-control, tess-eval,
          geometry, fragment, compute), 0 if that stage is absent.
      - id: reserved2
        size: 40
        doc: Completes the 96-byte `ShaderInfoData`.
      - id: len_memory
        type: u4
        doc: BinaryShaderLibrary `ShaderProgram.MemoryData` length.
      - id: reserved3
        type: u4
      - id: ofs_memory
        type: s8
      - id: ofs_parent
        type: s8
        doc: Back-pointer to the owning variation.
      - id: ofs_reflection
        type: s8
        doc: Absolute offset of the six per-stage reflection offsets.
      - id: reserved4
        size: 32
    instances:
      stages:
        value: ofs_stage
  source_stage:
    doc: 'Per-stage payload when the owning `shader_program.format` == 3.'
    seq:
      - id: num_code
        type: u2
      - id: reserved
        size: 6
      - id: ofs_size_array
        type: s8
      - id: ofs_offset_array
        type: s8
      - id: reserved2
        size: 8
  compressed_stage:
    doc: 'Per-stage payload when the owning `shader_program.compression` == zlib.'
    seq:
      - id: len_compressed
        type: u4
      - id: len_decompressed
        type: u4
      - id: ofs_code
        type: s8
        doc: Absolute offset of the zlib blob.
  binary_stage:
    doc: 'Per-stage payload otherwise (compiled machine code).'
    seq:
      - id: reserved
        size: 8
      - id: ofs_shader
        type: s8
      - id: ofs_shader2
        type: s8
      - id: len_shader
        type: s4
      - id: len_shader2
        type: s4
      - id: reserved2
        size: 32
enums:
  compression_type:
    0: none
    1: zlib
