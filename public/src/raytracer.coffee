# TODO
# you can declare global variables here
# ...

class Color
  constructor: (@r, @g, @b) ->

  toArray: ->
    [@r, @g, @b]


class Scene
  constructor: (@camera, @light) ->


class Camera
  constructor: (@position, @direction, @upDirection, @fieldOfView) ->


class Light
  constructor: (@color, @location, @intensity) ->


class Intensity
  constructor: (@ambient, @diffuse, @specular, @globalAmbient)->


class Sphere
  constructor: (@center, @radius) ->

# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  camera = new Camera([0, 0, 10], [0, 0, -1], [0, 1, 0], 40)
  light = new Light(new Color(1, 1, 1), [10, 10, 10], new Intensity(0, 1, 1, 0.2))
  this.scene = new Scene()



this.trace = (color, pixelX, pixelY) ->
  # 1. shoot a ray determined from the camera parameters and the pixel position in the image
  # 2. intersect the ray to scene elements and determine the closest one
  # 3. check if the intersection point is illuminated by each light source
  # 4. shade the intersection point using the meterial attributes and the lightings
  # 5. set the pixel color into the image buffer using the computed shading (for now set dummy color into the image buffer)
  c = new Color(pixelX / width,
    pixelY / height * 0.9,
    pixelX * pixelY / (width * height / 2))

  color.setElements(c.toArray());
