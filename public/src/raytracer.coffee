# TODO
# you can declare global variables here
# ...


class Color
  constructor: (r, g, b) ->
    r = 0 if r < 0
    g = 0 if g < 0
    b = 0 if b < 0
    r = 1 if r > 1
    g = 1 if g > 1
    b = 1 if b > 1
    @val = $V([r, g, b])
  toArray: ->
    [@val.elements[0], @val.elements[1], @val.elements[2]]
  add: (color) ->
    color.val
    v = @val.add(color.val)
    new Color(v.elements[0], v.elements[1], v.elements[2])
  multiply: (scale) ->
    new Color(@val.elements[0]*scale, @val.elements[1]*scale, @val.elements[2]*scale)


class Scene
  constructor: (@camera, @light) ->
    @objects = []

  addObject: (object) ->
    @objects[@objects.length] = object

  intersections: (ray) ->
    object for object in @objects when object.intersects(ray)

  firstIntersection: (ray) ->
    min = Infinity
    ret = null
    @objects.forEach (object) ->
      i = object.intersects(ray)
      if i && i < min
        min = i
        intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i))
        ret = [intersectionPoint, object]
    ret




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


class Light
  constructor: (@color, @location, @intensity) ->


class LightIntensity
  constructor: (@ambient, @diffuse, @specular, @globalAmbient)->


class ReflectionProperty
  constructor: (@ambientColor, @diffuseColor, @specularColor, @specularExponent) ->


class Sphere
  constructor: (@center, @radius, @reflectionProperties) ->
    @radiusSquared = @radius * @radius

  norm: (intersectionPoint) ->
    intersectionPoint.subtract(@center).toUnitVector()

  intersects: (ray) ->
    console.setRlog()
    console.rlog ""

    o = ray.line.anchor
    d = ray.line.direction
    c = @center

    # c-o
    c_minus_o = c.subtract(o)
    console.rlog "c_minus_o:"
    console.rlog c_minus_o

    # ||c-o||^2
    distSquared = c_minus_o.dot(c_minus_o)
    console.rlog "distSquared=" + distSquared

    # (c-o)*d
    rayDistanceClosestToCenter = c_minus_o.dot(d)
    console.rlog "rayDistanceClosestToCenter=" + rayDistanceClosestToCenter
    return false if rayDistanceClosestToCenter < 0

    # D^2 = ||c-o||^2 - ((c-o)*d)^2
    shortestDistanceFromCenterToRaySquared = distSquared - (rayDistanceClosestToCenter * rayDistanceClosestToCenter)
    console.rlog "shortestDistanceFromCenterToRay=" + shortestDistanceFromCenterToRaySquared
    console.rlog "@radiusSquared=" + @radiusSquared
    return false if shortestDistanceFromCenterToRaySquared > @radiusSquared

    # t = (o-c)*d ± sqrt(r^2 - D^2)
    x = @radiusSquared - shortestDistanceFromCenterToRaySquared
    return false if x < 0
    t = rayDistanceClosestToCenter - Math.sqrt(x)
    console.rlog "halfChordDistance=" + t
    t

class Ray
  constructor: (@line) ->

class RayTracer
  constructor: (@color, @pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    ray = this.castRay()

    # 2. intersect the ray to scene elements and determine the closest one
    intersection = @scene.firstIntersection(ray)

    c = new Color(0, 0, 0)
    if intersection
      console.rlog intersection[1]
      pos = intersection[0]
      obj = intersection[1]
      c = this.illuminate(pos, obj, ray)

    @color.setElements(c.toArray())

    # 3. check if the intersection point is illuminated by each light source

    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)


  illuminate: (pos, obj, ray) ->
    nv = obj.norm(pos)

    #obj.reflectionProperties.ambientColor

    w = ray.line.direction
    wl = @scene.light.location.subtract(pos).toUnitVector()
    #wr = ray.line.direction.reflectionIn(nv).toUnitVector()
    wr = nv.multiply(2).multiply(w.dot(nv)).subtract(w)

    globalAmbient = @scene.light.intensity.globalAmbient
    globalAmbientColor = obj.reflectionProperties.ambientColor.multiply(globalAmbient)

    ambient = @scene.light.intensity.ambient
    ambientColor = obj.reflectionProperties.ambientColor.multiply(ambient)

    kd = obj.reflectionProperties.diffuseColor
    E = @scene.light.intensity.diffuse * nv.dot(wl)
    diffuse = kd.multiply(E * @scene.light.intensity.diffuse)

    n = obj.reflectionProperties.specularExponent
    ks = obj.reflectionProperties.specularColor
    frac = Math.pow(wr.dot(wl), n) / nv.dot(wl)
    spepcularIntensity = frac * E
    spepcularIntensity = 0 if frac < 0
    specularHighlights = ks.multiply(spepcularIntensity)

    #distanceToLight = pos.distanceFrom(@scene.light.location)
    #E = @scene.light.intensity.diffuse / 4 / Math.PI / (distanceToLight * distanceToLight)


    #ls
    #specularReflection = ks.multiply(ls)

    #kt
    #specularRefraction = kt.multiply(lt)

    globalAmbientColor.add(ambientColor).add(diffuse).add(specularHighlights) #.add(specularReflection).add(specularRefraction)

    #E = n.dot(wl)


    #distanceToLight = pos.distanceFrom(@scene.light.location)
    #E = n.dot(w) * @scene.light.intensity.diffuse / 4 / Math.PI # / (distanceToLight * distanceToLight)
    #E = n.dot(wl)


    #specInt = Math.pow(wr.dot(wl), obj.reflectionProperties.specularExponent) / 4 / Math.PI / (distanceToLight * distanceToLight)
    #specColor = obj.reflectionProperties.specularColor.multiply(specInt)
    #E = n.dot(wl)
    #diffColor = obj.reflectionProperties.diffuseColor.multiply(E)
    #diffColor.add(obj.reflectionProperties.ambientColor)



  castRay: () ->
    camera = scene.camera

    centerPixelX = (@pixelX + 0.5 - camera.width / 2) / camera.height * camera.imagePaneHeight # + 0.5 for the center of the pixel
    centerPixelY = (-@pixelY - 0.5 + camera.height / 2) / camera.width  * camera.imagePaneWidth # - 0.5 for the center of the pixel

    rayDirection = camera.imageCenter.add(camera.upDirection.multiply(centerPixelX)).add(
      camera.rightDirection.multiply(centerPixelY)).subtract(camera.position)

    new Ray($L(camera.position, rayDirection))


# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  fieldOfView = 40 / 180 * Math.PI
  camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, 800, 600)
  light = new Light(new Color(1, 1, 1), $V([10, 10, 10]), new LightIntensity(0, 1, 1, 0.2))

  scene = new Scene(camera, light)

  scene.addObject(new Sphere($V([0, 0, 0]), 2,
    new ReflectionProperty(
      new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32)))

  scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
    new ReflectionProperty(
      new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16)))

  this.scene = scene


this.trace = (color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()
