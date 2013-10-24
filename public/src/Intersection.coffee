class Intersection
  constructor: (@figure, @ray) ->
    sol = @figure.solutions(@ray)

    if sol
      [t1, t2] = sol
      @distance = Math.min t1, t2
      @point = @ray.line.anchor.add(@ray.line.direction.multiply(@distance))
      @normal = @figure.norm(@point, @ray)

  exists: () ->
    @distance > RayConfig.intersectionDelta

  isNearerThen: (intersection) ->
    return true if intersection == null
    @distance < intersection.distance

  # Performance optimization
  @intersectionExists: (figure, ray) ->
    sol = figure.solutions(ray)
    return null unless sol
    Math.min(sol[0], sol[1])

