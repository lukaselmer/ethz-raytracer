class Scene
  constructor: (@camera, @globalAmbient) ->
    @objects = []
    @lights = []

  addLight: (light) ->
    @lights.push light

  addObject: (object) ->
    @objects.push object

  buildOctree: () ->
    if RayConfig.octree
      @octree = new Octree(null, 0)
      depth = Math.min(Math.floor(Math.log(@objects.length) / Math.log(8)), RayConfig.octreeMaxDepth)
      @octree = new Octree(BoundingBox.getBoundingBoxFromObjects(@objects), depth)
      for o in @objects
        @octree.insertObject o

  firstIntersection: (ray) ->
    this.buildOctree() unless @octree

    min = Infinity
    ret = null

    oo = @objects
    oo = @octree.getIntersectionObjects(ray) if RayConfig.octree

    for figure in oo
      i = figure.intersection(ray)
      continue unless i

      dist = i.distance
      if dist != null && dist < min
        ret = i
        min = dist
    ret
