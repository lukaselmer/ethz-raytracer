# 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
this.loadScene = () ->
  fieldOfView = 40 / 180 * Math.PI
  camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width, RayConfig.height)
  #camera = new Camera($V([0, 3, 10]), $V([0, -0.5, -1]), $V([0, 0, 1]), 1, fieldOfView, RayConfig.width, RayConfig.height)

  #scene = new Scene(camera, 0.2)
  scene = new Scene(camera, 0.2)
  scene.addLight(new Light(new Color(1, 1, 1), $V([10, 10, 10]), new LightIntensity(0, 1, 1)))
  #scene.addLight(new Light(new Color(1, 1, 1), $V([10, -10, 10]), new LightIntensity(0, 1, 1)))
  #scene.addLight(new Light(new Color(1, 1, 1), $V([10, 5, 10]), new LightIntensity(0, 1, 1)))

  scene.addObject(new Sphere($V([0, 0, 0]), 2,
    new ReflectionProperty(
      #new Color(0, 0, 0), new Color(0, 0, 0), new Color(1, 1, 1), 32)))
      new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)))

  scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
    new ReflectionProperty(
      new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

  this.scene = scene


this.trace = (color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()
