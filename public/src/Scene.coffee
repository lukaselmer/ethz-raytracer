class Scene
  constructor: (@camera, @globalAmbient) ->
    @objects = []
    @lights = []

  addLight: (light) ->
    @lights.push light

  addObject: (object) ->
    @objects.push object

  firstIntersection: (ray) ->
    min = null
    @objects.forEach (figure) ->
      intersection = new Intersection(figure, ray)

      if intersection.exists() && intersection.isNearerThen(min)
        min = intersection
    min
