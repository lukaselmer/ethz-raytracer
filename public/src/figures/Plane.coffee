class Plane
  constructor: (@point, @normal, @reflectionProperties) ->
    @normal = @normal.toUnitVector()

  norm: (intersectionPoint, ray) ->
    @normal

  intersection: (ray) ->
    c = ray.line.direction.dot(@normal)

    # the angle is zero
    return null if c == 0

    distance = @point.subtract(ray.line.anchor).dot(@normal) / c
    return null if distance < RayConfig.intersectionDelta

    epsilon = 0.01
    new Intersection(ray, this, this, distance, 0, @reflectionProperties)

  solutions: (ray) ->
    i = this.intersection(ray)
    return null unless i
    [i.t1, i.t2]
