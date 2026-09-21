meta:
  id: nurpdb
  file-extension: nurpdb
  endian: le
  title: Bandai Namco SSBH render-pass data (Super Smash Bros. Ultimate)
doc: |
  SSBH NRPD container (`.nurpdb`), Super Smash Bros. Ultimate. Reference:
  ultimate-research/ssbh_lib `ssbh_lib/src/formats/nrpd.rs` (`Nrpd::V16`).
  This is the least well-understood member of the SSBH family even in the
  reference itself -- most of its nested structs are named "Unk*"/"unk*"
  there and marked TODO, with several RelPtr64<u64> fields whose target
  isn't confidently known to be an array at all. Ported from
  `lib-nurpdb.c`/`.h`, whose own decoding scope is limited accordingly: the
  render pass's own per-pass data items (`RenderPassData`'s many variants)
  are not decoded here either.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x44, 0x50, 0x52, 0x4e] # "DPRN" ("NRPD" byte-reversed)
  - id: version_major
    type: u2
  - id: version_minor
    type: u2
  - id: frame_buffers
    type: ssbh_array
    doc: SsbhArray<SsbhEnum64<FrameBuffer>>.
  - id: state_containers
    type: ssbh_array
    doc: SsbhArray<SsbhEnum64<State>>.
  - id: render_passes
    type: ssbh_array
    doc: SsbhArray<RenderPassContainer>, element size 0x40.
  - id: unk_string_list1
    type: ssbh_array
    doc: SsbhArray<StringPair>, element size 0x10.
  - id: unk_string_list2
    type: ssbh_array
    doc: SsbhArray<SsbhEnum64<UnkItem2>>.
  - id: unk_list
    type: ssbh_array
    doc: SsbhArray<UnkItem1>, element size 0x18.
  - id: unk_width1
    type: u4
  - id: unk_height1
    type: u4
  - id: unk3
    type: u4
  - id: unk4
    type: u4
  - id: unk5
    type: u4
  - id: unk6
    type: u4
  - id: unk7
    type: u4
  - id: unk8
    type: u4
  - id: unk9
    type: ssbh_string
  - id: unk_width2
    type: u4
  - id: unk_height2
    type: u4
  - id: unk10
    type: u8
types:
  ssbh_array:
    seq:
      - id: ofs_rel
        type: u8
      - id: count
        type: u8
  ssbh_string:
    seq:
      - id: ofs_rel
        type: u8
  ssbh_enum64:
    doc: |
      16 bytes -- a u64 relative offset (relative to this field's own
      position) to the variant's payload, then a u64 discriminant selecting
      which variant it is. Every FrameBuffer/State/UnkItem2 variant this
      decoder cares about happens to start with a 'name: SsbhString' field.
    seq:
      - id: ofs_rel
        type: u8
      - id: discriminant
        type: u8
  render_pass_container:
    doc: 0x40 bytes, relative to render_passes's own element base.
    seq:
      - id: name
        type: ssbh_string
      - id: unk1
        type: ssbh_array
        doc: SsbhArray<SsbhEnum64<RenderPassData>>, count only decoded.
      - id: unk2
        type: ssbh_array
        doc: SsbhArray<SsbhEnum64<RenderPassData>>, count only decoded.
      - id: unk3
        type: ssbh_enum64
        doc: SsbhEnum64<RenderPassUnkData>, not decoded further.
      - id: padding
        size: 8
  string_pair:
    doc: 0x10 bytes.
    seq:
      - id: item1
        type: ssbh_string
      - id: item2
        type: ssbh_string
  unk_item3:
    doc: 0x10 bytes.
    seq:
      - id: name
        type: ssbh_string
      - id: value
        type: ssbh_string
  unk_item1:
    doc: 0x18 bytes.
    seq:
      - id: unk1
        type: ssbh_string
      - id: unk2
        type: ssbh_array
        doc: SsbhArray<UnkItem3>.
