class Intersection
  constructor: (@ray, @figure, @normalFigure, @t1, @t2, @reflectionProperties) ->
    @t1 = 0 if -RayConfig.intersectionDelta < @t1 < RayConfig.intersectionDelta
    @t2 = 0 if -RayConfig.intersectionDelta < @t2 < RayConfig.intersectionDelta

    if @t1 > 0 && @t2 > 0
      @distance = Math.min(@t1, @t2)
      @distance2 = Math.max(@t1, @t2)
    else if @t1 > 0 && @t2 <= 0
      @distance = @t1
      @distance2 = @t2
    else if @t2 > 0 && @t1 <= 0
      @distance = @t2
      @distance2 = @t2
    @normal = null
    @point = null

    #sol = @figure.solutions(@ray)
    #
    #if sol
    #  [t1, t2] = sol
    #  @distance = Math.min t1, t2
    #  @point = @ray.line.anchor.add(@ray.line.direction.multiply(@distance))
    #  @normal = @figure.norm(@point, @ray)

  getPoint: () ->
    @point = @ray.line.anchor.add(@ray.line.direction.multiply(@distance)) unless @point
    @point

  getNormal: () ->
    @normal = @normalFigure.norm(this.getPoint()) unless @normal
    @normal

  # Performance optimization
  @intersectionExists: (figure, ray) ->
    i = figure.intersection(ray)
    return null unless i
    i.distance
    #sol = figure.solutions(ray)
    #return null unless sol
    #Math.min(sol[0], sol[1])

