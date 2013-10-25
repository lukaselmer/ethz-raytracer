class Plane
  constructor: (@point, @normal, @reflectionProperties) ->
    @normal = @normal.toUnitVector()

  norm: (intersectionPoint, ray) ->
    @normal

  intersection: (ray) ->
    cos = ray.line.direction.dot(@normal)
    return null if cos == 0
    d = @point.subtract(ray.line.anchor).dot(@normal) / cos
    return null if d < RayConfig.intersectionDelta
    epsilon = 0.01
    new Intersection(ray, this, this, d, d - epsilon, @reflectionProperties)

  solutions: (ray) ->
    i = this.intersection(ray)
    return null unless i
    [i.t1, i.t2]

  #solutions: (ray) ->
  #  perpendicularArea = ray.line.direction.toUnitVector().dot(@normal) # .toUnitVector()?
  #  return null if perpendicularArea == 0
  #  distance = @point.subtract(ray.line.anchor).dot(@normal) / perpendicularArea
  #  return null if distance < RayConfig.intersectionDelta
  #  [distance, 0]
  #intersection: (ray) ->
  #  [t1, t2] = this.solutions(ray)
  #  new Intersection(ray, this, this, t1, t2, @reflectionProperties)
