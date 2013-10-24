class SphereSphereIntersection
  constructor: (@sphere1, @sphere2, @reflectionProperties) ->

  norm: (intersectionPoint) ->
    s1 = @sphere1.intersects(@ray)
    s2 = @sphere2.intersects(@ray)
    if s1 > s2
      @sphere1.norm(intersectionPoint)
    else
      @sphere2.norm(intersectionPoint)

  intersects: (ray) ->
    @ray = ray
    s1 = @sphere1.intersects(ray)
    s2 = @sphere2.intersects(ray)

    return false unless s1 && s2
    return Math.min(s1, s2)

