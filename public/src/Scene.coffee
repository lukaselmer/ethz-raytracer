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
      if i && i < min && i > RayConfig.intersectionDelta
        min = i
        intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i))
        ret = [intersectionPoint, object]
    ret
