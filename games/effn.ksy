meta:
  id: effn
  file-extension: effn
  endian: le
  title: Bandai Namco Effect File (EFFN)
doc: |
  Particle-effect metadata container used by Super Smash Bros. 4 (Wii U /
  3DS) and Super Smash Bros. Ultimate (Switch), magic `EFFN`. Ported from
  nintoolbox's `lib-effn.c`, itself based on KillzXGaming/EffectLibrary's
  `FileData/EFFN/NamcoEffectFile.cs`.

  Layout: a 16-byte header, then three fixed-size tables back to back
  (effect entries, multi-part variants, external-model flag bytes), then
  three parallel NUL-terminated UTF-8 string tables (one name per effect
  entry, one per external model, one per variant/"bone"), and finally an
  embedded NintendoWare `VFXB` particle archive (see the `pctl`/PTCL
  format) at the next `header_chunk_align`-byte boundary (4096 normally,
  8192 when `header_chunk_align` is 2).

  Effect entries, external models and variants cross-reference each other
  with 1-based indices (0 means "none"): an entry's `external_model_idx`
  selects a model flag byte + name, and `variant_start_idx`/`variant_count`
  select a contiguous run of the variant table.
seq:
  - id: magic
    contents: "EFFN"
  - id: version
    type: u4
  - id: num_effects
    type: u2
  - id: num_external_models
    type: u2
  - id: multi_part_effects
    type: u2
    doc: Total number of variant records across all effects.
  - id: header_chunk_align
    type: u2
    doc: "1: embedded VFXB aligned to 4096; 2: aligned to 8192."
  - id: entries
    type: effect_entry
    repeat: expr
    repeat-expr: num_effects
  - id: variants
    type: variant
    repeat: expr
    repeat-expr: multi_part_effects
  - id: external_model_flags
    type: u1
    repeat: expr
    repeat-expr: num_external_models
  - id: effect_names
    type: strz
    encoding: UTF-8
    repeat: expr
    repeat-expr: num_effects
  - id: external_model_names
    type: strz
    encoding: UTF-8
    repeat: expr
    repeat-expr: num_external_models
  - id: variant_bone_names
    type: strz
    encoding: UTF-8
    repeat: expr
    repeat-expr: multi_part_effects
doc-ref: KillzXGaming/EffectLibrary FileData/EFFN/NamcoEffectFile.cs
types:
  effect_entry:
    seq:
      - id: kind
        type: u2
      - id: unknown
        type: u2
      - id: emitter_set_id
        type: u4
      - id: external_model_idx
        type: u4
        doc: 1-based index into the external-model tables; 0 = none.
      - id: variant_start_idx
        type: u2
        doc: 1-based index into `variants`; 0 = none.
      - id: variant_count
        type: u2
  variant:
    seq:
      - id: start_frame
        type: u2
      - id: emitter_set_id
        type: u2
