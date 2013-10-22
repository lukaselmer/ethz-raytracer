class Camera
  constructor: (@position, @direction, @upDirection, @distance, @fieldOfView, @width, @height) ->
    this.calibrateCamera()

  calibrateCamera: () ->
    @direction = @direction.toUnitVector()
    @rightDirection = @direction.cross(@upDirection).toUnitVector()
    @upDirection = @rightDirection.cross(@direction).toUnitVector()
    @imagePaneHeight = 2 * Math.tan(@fieldOfView / 2) * @distance
    @imagePaneWidth = @imagePaneHeight / @height * @width

    @imageCenter = @position.add(@direction.multiply(@distance))
    @imageTop = @imageCenter.add(@upDirection.multiply(@imagePaneHeight / 2))
    @imageBottom = @imageCenter.add(@upDirection.multiply(-1 * @imagePaneHeight / 2))
    @imageLeft = @imageCenter.add(@rightDirection.multiply(-1 * @imagePaneWidth / 2))
    @imageRight = @imageCenter.add(@rightDirection.multiply(@imagePaneWidth / 2))

  getCenter: () ->
    @position.add(@direction)

class Color
  @random: () ->
    new Color(Math.random(), Math.random(), Math.random())
  constructor: (r, g, b) ->
    if r instanceof Vector
      g = r.elements[1]
      b = r.elements[2]
      r = r.elements[0]
    r = 0 if r < 0
    g = 0 if g < 0
    b = 0 if b < 0
    r = 1 if r > 1
    g = 1 if g > 1
    b = 1 if b > 1
    @val = $V([r, g, b])
  add: (color) ->
    new Color(@val.add(color.val))
  multiply: (scale) ->
    new Color(@val.multiply(scale))
  multiplyColor: (color) ->
    new Color(@val.elements[0] * color.val.elements[0], @val.elements[1] * color.val.elements[1],
      @val.elements[2] * color.val.elements[2])
  toArray: ->
    @val.dup().elements
  toVector: ->
    @val.dup()

class Light
  constructor: (@color, @location, @intensity) ->

class LightIntensity
  constructor: (@ambient, @diffuse, @specular)->

# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  fieldOfView = 40 / 180 * Math.PI
  camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height)
  #camera = new Camera($V([0, 3, 10]), $V([0, -0.5, -1]), $V([0, 0, 1]), 1, fieldOfView, RayConfig.width, RayConfig.height)

  scene = new Scene(camera, 0.2)
  scene.addLight(new Light(new Color(1, 1, 1), $V([10, 10, 10]), new LightIntensity(0, 1, 1)))
  #scene.addLight(new Light(new Color(1, 1, 1), $V([10, -10, 10]), new LightIntensity(0, 1, 1)))
  #scene.addLight(new Light(new Color(1, 1, 1), $V([10, 5, 10]), new LightIntensity(0, 1, 1)))

  if ModuleId.ALT
    # alternative scene
    c = Color.random()
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
    new ReflectionProperty(
      # ambientColor
      c,
      # diffuseColor
      c,
      # specularColor
      new Color(1, 1, 1),
      # specularExponent
      32,
      # refractionIndex
      1.5
    )))

    #new Color(0, 0, 0), new Color(0, 0, 0), new Color(1, 1, 1), 32)))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(
        # ambientColor
        c,
        # diffuseColor
        c,
        # specularColor
        new Color(0.5, 0.5, 1),
        # specularExponent
        16,
        # refractionIndex
        1.5
      )))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, -1.25, 3]), 0.5,
      new ReflectionProperty(
        # ambientColor
        c,
        # diffuseColor
        c,
        # specularColor
        new Color(0.5, 0.5, 1),
        # specularExponent
        16,
        # refractionIndex
        1.5
      )))

    c = Color.random()
    scene.addObject(new Sphere($V([0, -.75, 3]), 0.5,
      new ReflectionProperty(
        # ambientColor
        c,
        # diffuseColor
        c,
        # specularColor
        new Color(0.5, 0.5, 1),
        # specularExponent
        16,
        # refractionIndex
        1.5
      )))

    scene.addObject(new Sphere($V([2.5, 0, -1]), 0.5,
      new ReflectionProperty(
        # ambientColor
        new Color(0, 0, 0.75),
        # diffuseColor
        new Color(0, 0, 1),
        # specularColor
        new Color(0.5, 0.5, 1),
        # specularExponent
        16,
        # refractionIndex
        1.5
      )))
  else
    # original scene
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
      new ReflectionProperty(
        # ambientColor
        new Color(0.75, 0, 0),
        # diffuseColor
        new Color(1, 0, 0),
        # specularColor
        new Color(1, 1, 1),
        # specularExponent
        32,
        # refractionIndex
        Infinity
      )))

    #new Color(0, 0, 0), new Color(0, 0, 0), new Color(1, 1, 1), 32)))

    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(
        # ambientColor
        new Color(0, 0, 0.75),
        # diffuseColor
        new Color(0, 0, 1),
        # specularColor
        new Color(0.5, 0.5, 1),
        # specularExponent
        16,
        # refractionIndex
        1.5
      )))


  scene


this.trace = (scene, color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()

class Ray
  constructor: (@line, @refraction, @power) ->

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
    width: 600
    height: 800
    illumination: true
    reflection: ModuleId.B1
    refraction: ModuleId.B1
    antialiasing: if ModuleId.B2 then 4 else 1 # set to 1 for no antialiasing
    recDepth: 20

initRayConfig()

class RayTracer
  constructor: (@color, @pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    # 2. intersect the ray to scene elements and determine the closest one
    # 3. check if the intersection point is illuminated by each light source
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
    rays = this.castRays(RayConfig.antialiasing)

    traceRay = (ray) =>
      this.traceRec(ray, new Color(0, 0, 0), RayConfig.recDepth)

    colors = rays.map (ray) ->
      traceRay(ray)

    averageColorVector = colors.map((c) ->
      c.toVector()).reduce((previous, current) ->
      previous.add(current)).multiply(1 / colors.length)
    @color.setElements(averageColorVector.elements)

  traceRec: (ray, color, times) ->
    intersection = @scene.firstIntersection(ray)

    if intersection
      pos = intersection[0]
      obj = intersection[1]

      globalAmbient = @scene.globalAmbient
      globalAmbientColor = obj.reflectionProperties.ambientColor.multiply(globalAmbient)
      color = color.add(globalAmbientColor)

      if RayConfig.illumination
        for light in @scene.lights
          color = color.add(this.illuminate(pos, obj, ray, light))

      return color if times <= 0

      color = color.add(this.reflectAndRefract(pos, obj, ray, times)) if RayConfig.reflection
    color

  reflectAndRefract: (pos, obj, ray, times) ->
    [reflectedRay, refractedRay, reflectPower, refractPower] = this.specularRays(pos, obj, ray)
    color = new Color(0, 0, 0)
    specularReflection = new Color(0, 0, 0)
    specularRefraction = new Color(0, 0, 0)
    if reflectedRay?
      reflectedColor = this.traceRec(reflectedRay, specularReflection, times - 1)
      specularReflection = reflectedColor.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularReflection #.multiply(reflectPower)
    if refractedRay?
      refractedColor = this.traceRec(refractedRay, specularRefraction, times - 1)
      specularRefraction = refractedColor.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularRefraction #.multiply(refractPower)
    color

  #nv = obj.norm(pos)
  #w = ray.line.direction
  #wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1)
  #ks = obj.reflectionProperties.specularColor

  #specularReflection = this.traceRec(new Ray($L(pos, wr), ray.rafraction, 1), new Color(0, 0, 0), times - 1)
  #specularReflection = specularReflection.multiplyColor(ks)
  #specularReflection

  specularRays: (pos, obj, ray) ->
    inside = ray.refraction isnt 1

    # normal of intersection-point
    nv = obj.norm(pos)
    nv = nv.multiply(-1) if inside

    # view-direction
    w = pos.subtract(ray.line.anchor).toUnitVector()

    # angle between view-direction and normal
    w_dot_nv = w.dot(nv)

    # ray-reflection-direction: wr = 2n(w*n) - w
    wr = nv.multiply(2 * w_dot_nv).subtract(w).toUnitVector().multiply(-1)

    # refraction
    refractedRay = null
    n1 = ray.refraction
    n2 = (if inside then 1 else obj.reflectionProperties.refractionIndex)
    ref = n1 / n2
    reflectPower = ray.power
    refractPower = 0
    unless n2 is Infinity
      first = w.subtract(nv.multiply(w_dot_nv)).multiply(-ref)
      underRoot = 1 - (ref * ref) * (1 - (w_dot_nv * w_dot_nv))
      if underRoot >= 0
        # ray-refraction-direction
        wt = first.subtract(nv.multiply(Math.sqrt(underRoot))).toUnitVector()

        # fresnel equation
        cos1 = wr.dot(nv) # Math.cos(w_dot_n);
        cos2 = wt.dot(nv.multiply(-1)) # Math.cos(wr_dot_n);
        p_reflect = (n2 * cos1 - n1 * cos2) / (n2 * cos1 + n1 * cos2)
        p_refract = (n1 * cos1 - n2 * cos2) / (n1 * cos1 + n2 * cos2)
        reflectPower = 0.5 * (p_reflect * p_reflect + p_refract * p_refract) * ray.power
        refractPower = (1 - reflectPower) * ray.power

        refractedRay = new Ray($L(pos, wt), n2, refractPower)

    reflectedRay = new Ray($L(pos, wr), ray.refraction, reflectPower)
    reflectedRay = null if wr.elements[0] == 0 && wr.elements[0] == 0 && wr.elements[0] == 0 # hack! why does this happen?
    [reflectedRay, refractedRay, reflectPower, refractPower]


  illuminate: (pos, obj, ray, light) ->
    nv = obj.norm(pos)

    w = ray.line.direction
    wl = light.location.subtract(pos).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w).toUnitVector()

    return new Color(0, 0, 0) if @scene.intersections(new Ray($L(pos, wl), ray.refraction, 1)).length > 0

    ambient = light.intensity.ambient
    ambientColor = obj.reflectionProperties.ambientColor.multiply(ambient)

    kd = obj.reflectionProperties.diffuseColor
    E = light.intensity.diffuse * nv.dot(wl)
    diffuse = kd.multiply(E * light.intensity.diffuse)

    n = obj.reflectionProperties.specularExponent
    ks = obj.reflectionProperties.specularColor
    frac = Math.pow(wr.dot(wl), n) / nv.dot(wl)
    spepcularIntensity = frac * E
    spepcularIntensity = 0 if frac < 0
    specularHighlights = ks.multiply(spepcularIntensity)

    ambientColor.add(diffuse).add(specularHighlights)


  castRays: (antialiasing) ->
    camera = @scene.camera
    w = camera.width * antialiasing
    h = camera.height * antialiasing

    [1..antialiasing].map (i) =>
      [1..antialiasing].map (j) =>
        centerPixelX = (@pixelX * antialiasing + (i - 1) + 0.5 - w / 2) / h * camera.imagePaneHeight # + 0.5 for the center of the pixel
        centerPixelY = (-@pixelY * antialiasing - (j - 1) - 0.5 + h / 2) / w * camera.imagePaneWidth # - 0.5 for the center of the pixel

        rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(
          camera.rightDirection.multiply(centerPixelY)).subtract(camera.position)

        # Assume that the camera is not inside an object (otherwise, the refraction index would not be 1)
        new Ray($L(camera.position, rayDirection), 1, 1)
    .reduce((a, b) ->
        a.concat(b))

class ReflectionProperty
  constructor: (@ambientColor, @diffuseColor, @specularColor, @specularExponent, @refractionIndex) ->

class Scene
  constructor: (@camera, @globalAmbient) ->
    @objects = []
    @lights = []

  addLight: (light) ->
    @lights.push light

  addObject: (object) ->
    @objects.push object

  intersections: (ray) ->
    object for object in @objects when object.intersects(ray)

  firstIntersection: (ray) ->
    min = Infinity
    ret = null
    @objects.forEach (object) ->
      i = object.intersects(ray)
      if i && i < min && i > 0.00001
        min = i
        intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i))
        ret = [intersectionPoint, object]
    ret

class Sphere
  constructor: (@center, @radius, @reflectionProperties) ->
    @radiusSquared = @radius * @radius

  norm: (intersectionPoint) ->
    intersectionPoint.subtract(@center).toUnitVector()

  intersects: (ray) ->
    console.setRlog()
    #console.rlog ""

    o = ray.line.anchor
    d = ray.line.direction
    c = @center

    # c-o
    c_minus_o = c.subtract(o)
    #console.rlog "c_minus_o:"
    #console.rlog c_minus_o

    # ||c-o||^2
    distSquared = c_minus_o.dot(c_minus_o)
    #console.rlog "distSquared=" + distSquared

    # (c-o)*d
    rayDistanceClosestToCenter = c_minus_o.dot(d)
    #console.rlog "rayDistanceClosestToCenter=" + rayDistanceClosestToCenter
    return false if rayDistanceClosestToCenter < 0

    # D^2 = ||c-o||^2 - ((c-o)*d)^2
    shortestDistanceFromCenterToRaySquared = distSquared - (rayDistanceClosestToCenter * rayDistanceClosestToCenter)
    #console.rlog "shortestDistanceFromCenterToRay=" + shortestDistanceFromCenterToRaySquared
    #console.rlog "@radiusSquared=" + @radiusSquared
    return false if shortestDistanceFromCenterToRaySquared > @radiusSquared

    # t = (o-c)*d ± sqrt(r^2 - D^2)
    x = @radiusSquared - shortestDistanceFromCenterToRaySquared
    return false if x < 0
    t = rayDistanceClosestToCenter - Math.sqrt(x)
    #console.rlog "halfChordDistance=" + t
    t

### Random log ###
console.setRlog = (p = 0.0001) ->
  @shoulLog = Math.random() <= p
console.rlog = (msg) ->
  return unless @shoulLog
  console.log(msg)
