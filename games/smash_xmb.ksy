meta:
  id: smash_xmb
  endian: le
  title: Smash XMB material/LOD metadata (Super Smash Bros. 4/Ultimate)
doc: |
  Smash XMB material/LOD metadata, per lib-xmb.h (ported from
  Sammi-Husky/SSBU-TOOLS XMBDec.py / ultimate-research/xmb_lib).
seq:
  - id: magic
    contents: "XMB "
  - id: num_nodes
    type: u4
  - id: num_values
    type: u4
    doc: Informational -- sum of per-node property counts.
  - id: num_properties
    type: u4
    doc: Informational -- distinct property name string count.
  - id: num_mapped_nodes
    type: u4
  - id: string_offsets_table_offset
    type: u4
    doc: Informational index, unused on decode.
  - id: node_table_offset
    type: u4
  - id: property_table_offset
    type: u4
  - id: node_map_offset
    type: u4
  - id: names_table_offset
    type: u4
  - id: values_table_offset
    type: u4
instances:
  nodes:
    type: node_t
    repeat: expr
    repeat-expr: num_nodes
    pos: node_table_offset
  properties:
    type: property_t
    repeat: expr
    repeat-expr: num_values
    pos: property_table_offset
  node_map:
    type: node_map_entry_t
    repeat: expr
    repeat-expr: num_mapped_nodes
    pos: node_map_offset
types:
  node_t:
    seq:
      - id: name_offset
        type: u4
      - id: property_count
        type: s2
      - id: child_count
        type: s2
      - id: first_property_index
        type: s2
      - id: unk1
        type: s2
      - id: parent_index
        type: s2
        doc: -1 for the root.
      - id: unk2
        type: s2
    instances:
      name:
        pos: _root.names_table_offset + name_offset
        type: cstr
        io: _root._io
  property_t:
    seq:
      - id: name_offset
        type: u4
      - id: value_offset
        type: u4
    instances:
      name:
        pos: _root.names_table_offset + name_offset
        type: cstr
        io: _root._io
      value:
        pos: _root.values_table_offset + value_offset
        type: cstr
        io: _root._io
  node_map_entry_t:
    seq:
      - id: value_offset
        type: u4
      - id: node_index
        type: u4
    instances:
      id:
        pos: _root.values_table_offset + value_offset
        type: cstr
        io: _root._io
  cstr:
    seq:
      - id: value
        type: str
        terminator: 0
        encoding: UTF-8
