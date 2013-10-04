# TODO
# you can declare global variables here
# ...

class Color
  constructor: (@r, @g, @b) ->
  toArray: ->
    [@r, @g, @b]


class Scene
  constructor: (@camera, @light) ->
    @objects = []

  addObject: (object) ->
    @objects[@objects.length] = object

  intersections: (ray) ->
    object for object in @objects when object.intersects(ray)



class Camera
  constructor: (@position, @direction, @upDirection, @fieldOfView, @width, @height) ->
    this.calibrateCamera()

  calibrateCamera: () ->
    @rightDirection = @direction.cross(@upDirection)
    @upDirection = @rightDirection.cross(@direction)

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
  intersects: (ray) ->
    # TODO: implement this
    false

class Ray
  constructor: (@line) ->

class RayTracer
  constructor: (@color, @pixelX, @pixelY, @scene) ->

  trace: () ->
    # 1. shoot a ray determined from the camera parameters and the pixel position in the image
    rayDirection = this.castRay()

    # 2. intersect the ray to scene elements and determine the closest one
    intersections = @scene.intersections(rayDirection)
    if intersections.length > 0
      console.log intersections.length

    # 3. check if the intersection point is illuminated by each light source
    # 4. shade the intersection point using the meterial attributes and the lightings
    # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
    c = new Color(@pixelX / width,
      @pixelY / height * 0.9,
      @pixelX * @pixelY / (width * height / 2))

    @color.setElements(c.toArray());

  castRay: () ->
    camera = scene.camera
    [width, height] = [camera.width, camera.height]
    [centerPixelX, centerPixelY] = [(@pixelX / width) - 0.5, (@pixelY / height) - 0.5]
    camera.rightDirection.multiply(centerPixelX).add(camera.upDirection.multiply(centerPixelY)).add(camera.direction)


# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 40, 800, 600)
  light = new Light(new Color(1, 1, 1), [10, 10, 10], new LightIntensity(0, 1, 1, 0.2))

  scene = new Scene(camera, light)

  scene.addObject(new Sphere([0, 0, 0], 2,
    new ReflectionProperty(
      new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32)))

  scene.addObject(new Sphere([1.25, 1.25, 3], 0.5,
    new ReflectionProperty(
      new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16)))

  this.scene = scene


this.trace = (color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()
