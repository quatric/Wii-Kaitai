meta:
  id: numsh
  file-extension: numshb
  endian: le
  title: Bandai Namco SSBH mesh geometry (Super Smash Bros. Ultimate)
doc: |
  SSBH MESH container (`.numshb`), Super Smash Bros. Ultimate. Ported from
  `lib-numsh.c`/`.h`, whose header comment documents this format's fields
  as checked against 165 retail meshes rather than assumed (see that
  file's comment block for the validation notes on the mesh-object record
  size, attribute usage codes, and the index-offset field).

  Every pointer in the format is a 64-bit offset relative to the field
  that holds it, and an array is such a pointer followed by a 64-bit
  count.
seq:
  - id: magic
    contents: [0x48, 0x42, 0x53, 0x53] # "HBSS"
  - id: unk1
    type: u8
    doc: Always 0x40 on retail files.
  - id: sub_magic
    contents: [0x48, 0x53, 0x45, 0x4d] # "HSEM" ("MESH" byte-reversed)
  - id: version_major
    type: u2
    valid: 1
  - id: version_minor
    type: u2
    doc: 10 (v1.10) or 8 (v1.8).
  - id: model_name
    type: ssbh_string
  - id: bounding_sphere_center
    type: vector3
  - id: bounding_sphere_radius
    type: f4
  - id: bounding_box_min
    type: vector3
  - id: bounding_box_max
    type: vector3
  - id: oriented_bounding_box
    size: 60
    doc: 15 floats -- center, orientation matrix and size of an oriented box.
  - id: unk2
    type: u4
  - id: mesh_objects
    type: ssbh_array
    doc: SsbhArray<MeshObject>, element size 0xd0.
  - id: buffer_sizes
    type: ssbh_array
  - id: unk3
    type: u8
  - id: vertex_buffers
    type: ssbh_array
    doc: SsbhArray<VertexBuffer> -- each entry a pointer and a size.
  - id: index_buffer
    type: buffer_ptr
    doc: pointer, size.
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
  vector3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  buffer_ptr:
    seq:
      - id: ofs_rel
        type: u8
      - id: size
        type: u8
  mesh_object:
    doc: 0xd0 bytes.
    seq:
      - id: unk_head
        size: 0x18
      - id: vertex_count
        type: u4
      - id: index_count
        type: u4
      - id: unk1
        size: 4
      - id: vertex_buffer0_offset
        type: u4
      - id: vertex_buffer1_offset
        type: u4
      - id: unk2
        size: 4
      - id: vertex_buffer0_stride
        type: u4
      - id: vertex_buffer1_stride
        type: u4
      - id: unk3
        size: 8
      - id: index_buffer_offset
        type: u4
      - id: unk4
        size: 0x14
      - id: bounding_sphere_center
        type: vector3
      - id: unk5
        size: 4
      - id: bounding_box_min
        type: vector3
      - id: bounding_box_max
        type: vector3
      - id: unk6
        size: 0x44
      - id: attributes
        type: ssbh_array
        doc: SsbhArray<Attribute>, element size 0x30, at object offset 0xc0.
  attribute:
    doc: 0x30 bytes.
    seq:
      - id: usage
        type: u4
        doc: 0 position, 1 normal, 3 tangent, 4 color set, 5 texcoord.
      - id: data_type
        type: u4
        doc: 0 float3, 2 two halves, 5 four halves.
      - id: buffer_index
        type: u4
      - id: buffer_offset
        type: u4
        doc: Offset within that buffer's vertex.
  rigging_group:
    doc: 0x28 bytes -- one per mesh object, from the mesh header's last array.
    seq:
      - id: object_name
        type: ssbh_string
      - id: sub_index
        type: u8
      - id: flags
        type: u8
      - id: bone_buffers
        type: ssbh_array
        doc: SsbhArray<BoneBuffer>, element size 0x18.
  bone_buffer:
    doc: 0x18 bytes.
    seq:
      - id: bone_name
        type: ssbh_string
      - id: data
        type: buffer_ptr
        doc: pointer, size -- size is a multiple of 6 (see weight_entry).
  weight_entry:
    doc: 6 bytes.
    seq:
      - id: vertex_index
        type: u2
      - id: weight
        type: f4
