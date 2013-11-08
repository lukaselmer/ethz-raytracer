class SceneLoader
  constructor: () ->
    # 0. set up the scene described in the exercise sheet (this is called before the rendering loop)
    @scene = this.loadDefaults()

  loadDefaults: () ->
    fieldOfView = 40 / 180 * Math.PI
    #fieldOfView = 30 / 180 * Math.PI
    #camera = new Camera($V([2, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 1, fieldOfView, RayConfig.width,
    camera = new Camera($V([0, 0, 10]), $V([0, 0, -1]), $V([0, 1, 0]), 8.5, fieldOfView, RayConfig.width,
      RayConfig.height)
    #camera = new Camera($V([0, 3, 10]), $V([0, -0.5, -1]), $V([0, 0, 1]), 1, fieldOfView, RayConfig.width, RayConfig.height)

    scene = new Scene(camera, 0.2)
    scene.addLight(this.loadLight())
    #scene.addLight(new Light(new Color(1, 1, 1), $V([10, -10, 10]), new LightIntensity(0, 1, 1)))
    #scene.addLight(new Light(new Color(1, 1, 1), $V([10, 5, 10]), new LightIntensity(0, 1, 1)))
    scene

  loadLight: () ->
    if ModuleId.D2
      direction = $V([0,0,0]).subtract($V([10,10,10])).toUnitVector()
      new Light($V([10, 10, 10]), new Color(1, 1, 1), new LightIntensity(0, 1, 1),
        1, direction)
    else
      new Light($V([10, 10, 10]), new Color(1, 1, 1), new LightIntensity(0, 1, 1))

  loadScene: () ->
    scene = @scene

    if ModuleId.ALT
      this.loadAlternative(scene)
    else if ModuleId.B3
      this.loadB3(scene)
    else if ModuleId.B4
      this.loadB4(scene)
    else if ModuleId.C1
      this.loadC1(scene)
    else if ModuleId.C2
      this.loadC2(scene)
    else if ModuleId.C3
      this.loadC3(scene)
    else if ModuleId.D1
      this.loadD1(scene)
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

  ### new ReflectionProperty(ambientColor, diffuseColor, specularColor, specularExponent, refractionIndex ###
  loadC2: (scene) ->
    # original scene
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
      new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity),
      Texture.earth(), NormalMap.earth()))
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5),
      Texture.moon(), NormalMap.moon()))

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
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5))

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

  loadC1: (scene) ->
    scene.addObject(new Sphere($V([0, 0, 0]), 2,
      new ReflectionProperty(new Color(1, 1, 0), new Color(1, 1, 0), new Color(1, 1, 1), 32, Infinity)))
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(new Color(0, 1, 1), new Color(0, 1, 1), new Color(1, 1, 1), 32, Infinity)))
    #new ReflectionProperty(new Color(0, 1, 1), new Color(0, 1, 1), new Color(1, 1, 1), 16, 1.5)))

    if ModuleId.SP1
      scene.addObject(new Plane($V([0, -1, 0]), $V([1, 1, 0]),
        new ReflectionProperty(new Color(0, 0.75, 0.75), new Color(0, 1, 1), new Color(0.5, 1, 1), 16, Infinity)))


  loadC3: (scene) ->
    #resp = MeshLoader.loadMeshData("data/mini.obj")
    #resp = MeshLoader.loadMeshData("data/sphere.obj")
    unless ModuleId.SP1
      resp = MeshLoader.loadMeshData("data/sphere.obj")
      sphereMesh1 = new MeshLoader(resp, $V([0, 0, 0]), 2).createMesh()
      sphereMesh1.reflectionProperties = new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)
      sphereMesh2 = new MeshLoader(resp, $V([1.25, 1.25, 3]), 0.5).createMesh()
      sphereMesh2.reflectionProperties = new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)
      scene.addObject sphereMesh1
      scene.addObject sphereMesh2
    else
      #resp = MeshLoader.loadMeshData("data/teapot.obj")
      #sphereMesh1 = new MeshLoader(resp, $V([0, 0, 0]), 0.2).createMesh()
      #sphereMesh1.reflectionProperties = new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)
      #scene.addObject sphereMesh1
      #resp = MeshLoader.loadMeshData("data/neoSimian-organic.obj")
      #resp = MeshLoader.loadMeshData("data/neoSimian-mech.obj")
      sphereMesh2 = null
      if(Math.random() > 0.5)
        resp = MeshLoader.loadMeshData("data/ateneam.obj")
        sphereMesh2 = new MeshLoader(resp, $V([0, 0, 0]), 0.0004).createMesh()
      else
        resp = MeshLoader.loadMeshData("data/dragon.obj")
        sphereMesh2 = new MeshLoader(resp, $V([0, 0, 0]), 0.2).createMesh()
      sphereMesh2.reflectionProperties = new ReflectionProperty(new Color(0.75, 0, 0), new Color(1, 0, 0), new Color(1, 1, 1), 32, Infinity)
      scene.addObject sphereMesh2

  loadD1: (scene) ->
    for i in [0..9]
      for j in [0..9]
        for k in [0..9]
          scene.addObject new Sphere($V([i - 4.5, j - 4.5, -Math.pow(k, 3)]), 0.25,
            new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5))


  loadAlternative: (scene) ->
    # alternative scene
    c = Color.random()
    scene.addObject(new Sphere($V([-3, 3, 0]), 2,
      new ReflectionProperty(c, c, new Color(1, 1, 1), 32, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, 1.25, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([1.25, -1.25, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    c = Color.random()
    scene.addObject(new Sphere($V([-1, -0.75, 3]), 0.5,
      new ReflectionProperty(c, c, new Color(0.5, 0.5, 1), 16, 1.5)))

    scene.addObject(new Sphere($V([2.5, 0, -1]), 0.5,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5)))

    sphere1 = new Sphere($V([0, 0.5, 3]), 1, null)
    sphere2 = new Sphere($V([0, -0.5, 3]), 1, null)
    m1 = new MultipleObjectsIntersection(sphere1, sphere2, null)
    sphere1 = new Sphere($V([0.5, 0, 3]), 1, null)
    sphere2 = new Sphere($V([-0.5, 0, 3]), 1, null)
    m2 = new MultipleObjectsIntersection(sphere1, sphere2, null)

    mtot = new MultipleObjectsIntersection(m1, m2,
      new ReflectionProperty(new Color(0, 0, 0.75), new Color(0, 0, 1), new Color(0.5, 0.5, 1), 16, 1.5))
    scene.addObject(mtot)


this.SceneLoader = SceneLoader

this.trace = (scene, color, pixelX, pixelY) ->
  rayTracer = new RayTracer(color, pixelX, pixelY, scene)
  rayTracer.trace()
