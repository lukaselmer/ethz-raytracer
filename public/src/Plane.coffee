class Plane
  constructor: (@point, @normal, @reflectionProperties) ->
    @normal = @normal.toUnitVector()

  norm: (intersectionPoint, ray) ->
    @normal

  solutions: (ray) ->
    perpendicularArea = ray.line.direction.dot(@normal)
    return null if perpendicularArea == 0
    d = @point.subtract(ray.line.anchor).dot(@normal) / perpendicularArea
    return null if d < RayConfig.intersectionDelta
    [d, 0]
