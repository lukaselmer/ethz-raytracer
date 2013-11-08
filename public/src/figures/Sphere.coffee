class Sphere
  constructor: (@center, @radius, @reflectionProperties, @texture, @normalmap) ->
    @radiusSquared = @radius * @radius
    @boundingBoxCache = new BoundingBox(@center.e(1) + @radius, @center.e(1) - @radius, @center.e(2) + @radius, @center.e(2) - @radius, @center.e(3) + @radius, @center.e(3) - @radius)

    @northDirection = $V([0, 1, 1]).toUnitVector()
    @meridianDirection = $V([-1, 1, -1]).toUnitVector()

  norm: (intersectionPoint, ray) ->
    intersectionPoint.subtract(@center).toUnitVector()

  boundingBox: () ->
    @boundingBoxCache
  getBoundingBox: () ->
    @boundingBoxCache

  isLeft: (plane) ->
    @boundingBoxCache.right >= plane.point.e(1)
  isRight: (plane) ->
    @boundingBoxCache.left <= plane.point.e(1)
  isTop: (plane) ->
    @boundingBoxCache.top >= plane.point.e(2)
  isBottom: (plane) ->
    @boundingBoxCache.bottom <= plane.point.e(2)
  isBack: (plane) ->
    @boundingBoxCache.back >= plane.point.e(3)
  isFront: (plane) ->
    @boundingBoxCache.front <= plane.point.e(3)

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

  getInclination: (unitVector) ->
    x = unitVector.e(1)
    y = unitVector.e(2)
    z = unitVector.e(3)
    Math.acos y

  getAzimuth: (unitVector) ->
    x = unitVector.e(1)
    y = unitVector.e(2)
    z = unitVector.e(3)
    azimuth = Math.atan(x / z)
    if z < 0
      azimuth += Math.PI
    else azimuth += Math.PI * 2  if x < 0
    azimuth

  calcUV: (intersectionPoint) ->
    center_to_point = intersectionPoint.subtract(@center).toUnitVector()
    origin = $V([0, 0, 0])
    rightDirection = $V([1, 0, 0])
    upDirection = $V([0, 1, 0])
    frontDirection = $V([0, 0, 1])
    meridianAngle = -Math.acos(@meridianDirection.dot(frontDirection))
    center_to_point = center_to_point.rotate(meridianAngle, $L($V([0, 0, 0]), upDirection))
    upDirection = upDirection.rotate(meridianAngle, $L(origin, upDirection))
    rightDirection = rightDirection.rotate(meridianAngle, $L(origin, upDirection))
    frontDirection = frontDirection.rotate(meridianAngle, $L(origin, upDirection))
    northAngle = -Math.acos(@northDirection.dot(upDirection))
    center_to_point = center_to_point.rotate(northAngle, $L(origin, rightDirection))
    upDirection = upDirection.rotate(northAngle, $L(origin, rightDirection))
    rightDirection = rightDirection.rotate(northAngle, $L(origin, rightDirection))
    frontDirection = frontDirection.rotate(northAngle, $L(origin, rightDirection))
    inclination = @getInclination(center_to_point)
    azimuth = @getAzimuth(center_to_point)
    u = azimuth / (2 * Math.PI)
    v = -(inclination / Math.PI) + 1
    [u, v]