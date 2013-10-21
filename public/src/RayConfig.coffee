this.initRayConfig = () ->
  this.RayConfig =
    width: 600
    height: 800
    illumination: true
    reflection: true
    antialiasing: if ModuleId.B2 then 4 else 1 # set to 1 for no antialiasing
    recDepth: 10

initRayConfig()
