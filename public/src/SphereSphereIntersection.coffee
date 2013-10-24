class SphereSphereIntersection
  constructor: (@sphere1, @sphere2, @reflectionProperties) ->

  norm: (intersectionPoint) ->
    s1 = @sphere1.intersects(@ray)
    s2 = @sphere2.intersects(@ray)
    if s1 > s2
      @sphere1.norm(intersectionPoint)
    else
      @sphere2.norm(intersectionPoint)

  solutions: (ray) ->
    @ray = ray
    s1 = @sphere1.intersects(ray)
    s2 = @sphere2.intersects(ray)

    return false unless s1 && s2
    [s1, s2]

  ###intersection: (ray) ->
    i = this.intersects(ray)
    return false unless i

    intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i))
    normal = this.norm(intersectionPoint)
    [i, intersectionPoint, normal]###
