# TODO
# you can declare global variables here
# ...


class Color
  constructor: (r, g, b) ->
    @val = $V([r, g, b])
  toArray: ->
    [@val.elements[0], @val.elements[1], @val.elements[2]]
  add: (color) ->
    color.val
    v = @val.add(color.val)
    new Color(v.elements[0], v.elements[1], v.elements[2])


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
        ret = object
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
      console.rlog intersection
      c = c.add(intersection.reflectionProperties.ambientColor)

    #    if intersections.length > 0
    #      console.rlog intersections
    #      c = intersections[intersections.length - 1].reflectionProperties.ambientColor

    @color.setElements(c.toArray())


    # 3. check if the intersection point is illuminated by each light source
    
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)


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
