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
      i = figure.intersection(ray)
      continue unless i

      dist = i.distance
      if dist != null && dist < min
        ret = i
        min = dist
    ret
