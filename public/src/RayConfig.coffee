this.ModuleId =
  B1: `undefined` #... specular reflection/refraction and recursive ray tracing
  B2: `undefined` #... anti-aliasing
  B3: `undefined` #... quadrics
  B4: `undefined` #... CSG primitives
  C1: `undefined` #... stereo
  C2: `undefined` #... texture mapping
  C3: `undefined` #... meshes
  D1: `undefined` #... octree
  D2: `undefined` #... area light
  ALT: `undefined` #... alternative scene
  SP1: `undefined` #... adds special objects to the scene

if document? && $?
  $(document).ready ->
    unless document.location.toString().indexOf("?") is -1
      query = document.location.toString().replace(/^.*?\?/, "").replace("#", "").split("&")
      query.forEach (q) ->
        tmp = q.split("=")
        k = tmp[0]
        v = tmp[1]
        if v is `undefined` or v is "1" or v is "true"
          v = true
        else
          v = false
        ModuleId[k] = v

    for k of ModuleId
      v = ModuleId[k]
      checkbox = document.createElement("input")
      checkbox.type = "checkbox"
      checkbox.value = 1
      checkbox.name = k
      checkbox.id = k
      checkbox.setAttribute "checked", "checked"  if v
      label = document.createElement("label")
      label.setAttribute "class", "btn btn-primary" + ((if v then " active" else ""))
      label.appendChild checkbox
      $(label).data "option", k
      label.innerHTML += k
      $("#renderOptions").append label

this.initRayConfig = () ->
  this.RayConfig =
    width: 800 #800
    height: 600 #600
    illumination: true
    reflection: ModuleId.B1
    refraction: ModuleId.B1
    antialiasing: if ModuleId.B2 then 4 else 1 # set to 1 for no antialiasing
    antialiasingTechnique: 'grid' # options: grid, random, jittered
    recDepth: 2
    intersectionDelta: 0.00001
    strongRefraction: true
    octreeMaxDepth: 5

initRayConfig()
