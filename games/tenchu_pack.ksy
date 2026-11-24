meta:
  id: tenchu_pack
  title: Tenchu 4 .earc / .ires pack
  endian: be
doc: |
  Two of Tenchu 4's three offset-table layouts. `.earc` entries are
  {offset, size, kind, 0}; `.ires` entries are {offset, size, 0}. Members are
  stored back to back. Choose `layout` by the file extension.
params:
  - id: has_kind
    type: bool
seq:
  - id: count
    type: u4
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: count
types:
  entry:
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: kind
        type: u4
        if: _root.has_kind
      - id: zero
        type: u4
