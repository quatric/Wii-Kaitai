meta:
  id: toshi_trz
  title: Blue Tongue Toshi PBProperties tree (.trz, Barnyard Wii)
  endian: be
doc: |
  Inside the decompressed TSFB section; all pointers are section offsets.
  PBProperties {parent, PBProperty *props, u32 count}; PBProperty {name ptr,
  value ptr}; PBPropertyValue {u32 type (0 int, 1 u32, 2 float, 3 bool, 4
  properties, 5 property name, 6 array, 7 string, 8 locale string index),
  u32 value}; PBPropertyValueArray {values ptr, u32 count}.
seq:
  - id: parent
    type: u4
  - id: props_ptr
    type: u4
  - id: count
    type: u4
types:
  property:
    seq:
      - id: name_ptr
        type: u4
      - id: value_ptr
        type: u4
  value:
    seq:
      - id: type
        type: u4
        enum: kind
      - id: raw
        type: u4
  array:
    seq:
      - id: values_ptr
        type: u4
      - id: count
        type: u4
enums:
  kind:
    0: int
    1: u32
    2: float
    3: bool
    4: properties
    5: property_name
    6: array
    7: string
    8: locale_string_index
