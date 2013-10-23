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
  #fieldOfView = 40 / 180 * Math.PI
  fieldOfView = 30 / 180 * Math.PI
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
  isInside: () ->
    @refraction != 1
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
    width: 400*2 #800
    height: 300*2 #600
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

    console.setRlog()

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
    [reflectedRay, refractedRay] = this.specularRays(pos, obj, ray)
    color = new Color(0, 0, 0)
    if reflectedRay?
      specularReflection = this.traceRec(reflectedRay, new Color(0, 0, 0), times - 1)
      specularReflection = specularReflection.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularReflection.multiply(reflectedRay.power)
    if refractedRay?
      specularRefraction = this.traceRec(refractedRay, new Color(0, 0, 0), times - 1)
      if ray.refraction != 1
        specularRefraction = specularRefraction.multiplyColor(obj.reflectionProperties.specularColor)
      color = color.add specularRefraction.multiply(refractedRay.power) #* 0.5
    color

  #nv = obj.norm(pos)
  #w = ray.line.direction
  #wr = nv.multiply(2 * w.dot(nv)).subtract(w).toUnitVector().multiply(-1)
  #ks = obj.reflectionProperties.specularColor

  #specularReflection = this.traceRec(new Ray($L(pos, wr), ray.rafraction, 1), new Color(0, 0, 0), times - 1)
  #specularReflection = specularReflection.multiplyColor(ks)
  #specularReflection

  specularRays: (pos, obj, ray) ->
    # the norm n (unit vector)
    n = obj.norm(pos)
    # the view direction / input ray i (vector)
    i = pos.subtract(ray.line.anchor)
    n1 = ray.refraction
    n2 = obj.reflectionProperties.refractionIndex
    # the angle theta θ = i*n
    i_dot_n = i.dot(n)
    cos_theta_i = -i_dot_n
    #cos_theta_i = -cos_theta_i if ray.isInside()

    # === reflection ===

    # reflection ray r (unit vector)
    reflectionDirection = i.add(n.multiply(2 * cos_theta_i))

    # === refraction ===

    # Total reflection!
    if n2 == Infinity
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

    ratio = n1 / n2
    sin_theta_t_2 = Math.square(ratio) * (1 - Math.square(cos_theta_i))

    if sin_theta_t_2 > 1
      # Total reflection!
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

    cos_theta_t = Math.sqrt(1 - sin_theta_t_2)
    refractionDirection = i.multiply(ratio).add(n.multiply((ratio * cos_theta_i) - cos_theta_t))

    # Ok, both reflection and refraction exist => how is the ratio of the power? => frensel approximation
    # Note: we could also use the schlick's approximation which would be a little bit faster but less exact
    r1 = Math.square((n1 * cos_theta_i - n2 * cos_theta_t) / (n1 * cos_theta_i + n2 * cos_theta_t))
    r2 = Math.square((n2 * cos_theta_i - n1 * cos_theta_t) / (n2 * cos_theta_i + n1 * cos_theta_t))
    reflectionPowerRatio = (r1 + r2) / 2
    refractionPowerRatio = 1 - reflectionPowerRatio

    unless 0 <= reflectionPowerRatio <= 1 && 0 <= refractionPowerRatio <= 1
      # Total reflection!
      return [new Ray($L(pos, reflectionDirection), n1, ray.power), null]

    throw "Invalid state: reflectionPowerRatio: #{reflectionPowerRatio}, refractionPowerRatio: #{refractionPowerRatio}" unless 0 <= reflectionPowerRatio <= 1 && 0 <= refractionPowerRatio <= 1

    return [new Ray($L(pos, reflectionDirection), n1, ray.power * reflectionPowerRatio),
            new Ray($L(pos, refractionDirection), n2, ray.power * refractionPowerRatio)] # * 0.5 : why here * 0.5

  ###
    # normal of intersection-point
    #n = obj.norm(pos)
    n = n.multiply(-1) if ray.isInside()

    # view-direction
    w = ray.line.anchor.subtract(pos).toUnitVector()

    # angle between view-direction and normal
    w_dot_nv = w.dot(n)

    # ray-reflection-direction: wr = 2n(w*n) - w
    wr = n.multiply(2 * w_dot_nv).subtract(w).toUnitVector()

    # refraction
    refractedRay = null
    n1 = ray.refraction
    n2 = (if ray.isInside() then 1 else obj.reflectionProperties.refractionIndex)
    ref = n1 / n2
    reflectPower = 0
    refractPower = 0
    unless n2 is Infinity
      first = w.subtract(n.multiply(w_dot_nv)).multiply(-ref)
      underRoot = 1 - (ref * ref) * (1 - (w_dot_nv * w_dot_nv))

      if underRoot < 0 && !ray.isInside()
        throw "underRoot < 0 && !ray.isInside()"

      if underRoot >= 0
        # ray-refraction-direction
        wt = first.subtract(n.multiply(Math.sqrt(underRoot))).toUnitVector()

        # fresnel equation
        cos1 = wr.dot(n) # Math.cos(w_dot_n);
        cos2 = wt.dot(n.multiply(-1)) # Math.cos(wr_dot_n);
        p_reflect = (n2 * cos1 - n1 * cos2) / (n2 * cos1 + n1 * cos2)
        p_refract = (n1 * cos1 - n2 * cos2) / (n1 * cos1 + n2 * cos2)
        reflectPower = ((p_reflect * p_reflect) + (p_refract * p_refract)) * ray.power #* 0.5
        refractPower = (1 - reflectPower) * ray.power #* 0.5

        refractedRay = new Ray($L(pos, wt), n2, refractPower)
      else
        reflectPower = ray.power

    reflectedRay = new Ray($L(pos, wr), ray.refraction, reflectPower)
    [reflectedRay, refractedRay]
  ###

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
console.setRlog = (p = 0.01) ->
  @shoulLog = Math.random() <= p
console.rlog = (msg) ->
  return unless @shoulLog
  console.log(msg)

Math.square = (num) -> num * num
