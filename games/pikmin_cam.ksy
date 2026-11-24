meta:
  id: pikmin_cam
  title: Pikmin 1 camera parameters (camepara.bin)
  file-extension: bin
  endian: be
doc: |
  Pikmin 1 `camera/camepara.bin` (`PcamCameraParameters` in the decompilation):
  float parameters in declaration order (55 in the current version, the older
  files have 54).
seq:
  - id: version
    type: s4
  - id: camera_switch
    type: s4
  - id: parameters
    type: f4
    repeat: eos
