class SceneLoader
  constructor: () ->
    # 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
    @scene = this.loadDefaults()

  loadDefaults: () ->
    fieldOfView = 40 / 180 * Math.PI
    #fieldOfView = 30 / 180 * Math.PI
    camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width,
      RayConfig.height)
    #camera = new Camera($V([0, 3, 10]), $V([0, -0.5, -1]), $V([0, 0, 1]), 1, fieldOfView, RayConfig.width, RayConfig.height)

    scene = new Scene(camera, 0.2)
    scene.addLight(new Light($V([10, 10, 10]), new Color(1, 1, 1), new LightIntensity(0, 1, 1)))
    #scene.addLight(new Light(new Color(1, 1, 1), $V([10, -10, 10]), new LightIntensity(0, 1, 1)))
    #scene.addLight(new Light(new Color(1, 1, 1), $V([10, 5, 10]), new LightIntensity(0, 1, 1)))
    scene

  loadScene: () ->
    scene = @scene

    if ModuleId.ALT
      this.loadAlternative(scene)
    else if ModuleId.B3
      this.loadB3(scene)
    else if ModuleId.B4
      this.loadB4(scene)
    else
      this.loadOriginal(scene)

    scene

  ### new ReflectionProperty(ambientColor, diffuseColor, specularColor, specularExponent, refractionIndex ###
  loadOriginal: (scene) ->
    # original scene
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
      new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)))
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

    if ModuleId.SP1
      scene.addObject(new Plane($V([0, -1, 0]), $V([1, 1, 0]),
        new ReflectionProperty(new Color(0, 0.75, 0.75), new Color(0, 1, 1), new Color(0.5, 1, 1), 16, Infinity)))

  loadB3: (scene) ->
    # Quadrics

    # axis line, fixed x,y,z axis, radii, reflection properties
    #scene.addObject new Cylinder($V([0, 0, 0]), false, true, false, 2, 0, 0.1,
    #scene.addObject new Cylinder($V([0, 0, 0]), false, true, false, 3, 0, 1,
    scene.addObject new Cylinder($V([0, 0, 0]), false, true, false, 2, 0, 1,
      new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32,
        Infinity))
    # center, x,y,z radii, reflection properties
    #scene.addObject new Ellipsoid($V([1.25, 1.25, 3]), 0.5, 0.5, 0.5,
    scene.addObject new Ellipsoid($V([1.25, 1.25, 3]), 0.25, 0.75, 0.5,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16.0,
        1.5))

    if ModuleId.SP1
      scene.addObject(new Sphere($V([2.25, 1.25, 3]), 0.5,
        new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

      scene.addObject(new Sphere($V([-1.25, -1.25, 3]), 0.5,
        new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

      scene.addObject(new Sphere($V([0, 0, 3]), 0.5,
        new ReflectionProperty(new Color(1, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

  loadB4: (scene) ->
    # Boolean operations
    sphere1 = new Sphere($V([1.25, 1.25, 3]), 0.5, null)
    sphere2 = new Sphere($V([0.25, 1.25, 3]), 1, null)
    scene.addObject new MultipleObjectsIntersection(sphere1, sphere2,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, Infinity))

    red = new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32.0, Infinity)
    yellow = new ReflectionProperty(new Color(0.75, 0.75, 0), new Color(1, 1, 0), new Color(1, 1, 1), 32.0, Infinity)
    scene.addObject new Hemisphere(
      new Sphere($V([0, 0, 0]), 2, red),
      new Plane($V([0, 0, 0]), $V([-1, 0, 1]).toUnitVector(), yellow))


    if ModuleId.SP1
      sphere1 = new Sphere($V([0, 0.5, 3]), 1, null)
      sphere2 = new Sphere($V([0, -0.5, 3]), 1, null)
      m1 = new MultipleObjectsIntersection(sphere1, sphere2, null)
      sphere1 = new Sphere($V([0.5, 0, 3]), 1, null)
      sphere2 = new Sphere($V([-0.5, 0, 3]), 1, null)
      m2 = new MultipleObjectsIntersection(sphere1, sphere2, null)

      mtot = new MultipleObjectsIntersection(m1, m2,
        new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5))
      scene.addObject(mtot)

      cylinder = new Cylinder($V([0, 0, 0]), false, true, false, 2, 0, 1, null)
      sphere1 = new Sphere($V([-2, 1.25, 0]), 1, null)

      #scene.addObject cylinder
      #scene.addObject sphere1
      scene.addObject new MultipleObjectsIntersection(cylinder, sphere1, new ReflectionProperty(new Color(0.75, 0, 0),
        new Color(1, 0, 0), new Color(1, 1, 1), 32, 1.75))




  loadAlternative: (scene) ->
    # alternative scene
    c = Color.random()
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
      new ReflectionProperty(c, c, new Color(1, 1, 1), 32, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, -1.25, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([0, -.75, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    scene.addObject(new Sphere($V([2.5, 0, -1]), 0.5,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))


this.SceneLoader = SceneLoader

this.trace = (scene, color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()
