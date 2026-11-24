meta:
  id: nxof_nxms
  title: Switch Opus wrappers (nxof and NXMS)
  imports:
    - /games/nxof
    - /games/nxms
doc: |
  Two different headers decoded through the same Opus repacker: Nihon Falcom
  "nxof" (.nxopus) and Arika "NXMS" (.nxms). Pick the matching instance by magic.
instances:
  as_nxof:
    pos: 0
    type: nxof
  as_nxms:
    pos: 0
    type: nxms
