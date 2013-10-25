class Scene
  constructor: (@camera, @globalAmbient) ->
    @objects = []
    @lights = []

  addLight: (light) ->
    @lights.push light

  addObject: (object) ->
    @objects.push object

  firstIntersection: (ray) ->
    min = Infinity
    ret = null
    for figure in @objects
      dist = Intersection.intersectionExists(figure, ray)
      if dist != null && dist < min #&& dist > RayConfig.intersectionDelta
        ret = figure.intersection(ray)
        min = dist
    ret
