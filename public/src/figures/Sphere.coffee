class Sphere
  constructor: (@center, @radius, @reflectionProperties) ->
    @radiusSquared = @radius * @radius

  norm: (intersectionPoint, ray) ->
    intersectionPoint.subtract(@center).toUnitVector()

  solutions: (ray) ->
    o = ray.line.anchor
    d = ray.line.direction
    c = @center

    # c-o
    c_minus_o = c.subtract(o)
    #console.rlog "c_minus_o:"
    #console.rlog c_minus_o

    # ||c-o||^2
    distSquared = c_minus_o.dot(c_minus_o)
    #console.rlog "distSquared=" + distSquared

    # (c-o)*d
    rayDistanceClosestToCenter = c_minus_o.dot(d)
    #console.rlog "rayDistanceClosestToCenter=" + rayDistanceClosestToCenter
    return false if rayDistanceClosestToCenter < 0

    # D^2 = ||c-o||^2 - ((c-o)*d)^2
    shortestDistanceFromCenterToRaySquared = distSquared - (rayDistanceClosestToCenter * rayDistanceClosestToCenter)
    #console.rlog "shortestDistanceFromCenterToRay=" + shortestDistanceFromCenterToRaySquared
    #console.rlog "@radiusSquared=" + @radiusSquared
    return false if shortestDistanceFromCenterToRaySquared > @radiusSquared

    # t = (o-c)*d ± sqrt(r^2 - D^2)
    x = @radiusSquared - shortestDistanceFromCenterToRaySquared
    return null if x < 0
    t1 = rayDistanceClosestToCenter - Math.sqrt(x)
    t2 = rayDistanceClosestToCenter + Math.sqrt(x)
    return [t2, t2] if t1 < RayConfig.intersectionDelta
    return [t1, t1] if t2 < RayConfig.intersectionDelta
    [t1, t2]

  intersection: (ray) ->
    i = this.solutions(ray)
    return null unless i
    [t1, t2] = i
    new Intersection(ray, this, this, t1, t2, @reflectionProperties)
