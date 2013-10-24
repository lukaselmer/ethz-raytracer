# From: http://cudaopencl.blogspot.ch/2012/12/ellipsoids-finally-added-to-ray-tracing.html#

class Ellipsoid
  constructor: (@center, @radius_x, @radius_y, @radius_z, @reflectionProperties) ->
    @radius_x_2 = Math.square @radius_x
    @radius_y_2 = Math.square @radius_y
    @radius_z_2 = Math.square @radius_z

  norm: (intersectionPoint) ->
    n = intersectionPoint.subtract(@center)
    t = $M([
      [2.0 / @radius_x_2, 0, 0],
      [0, 2.0 / @radius_y_2, 0],
      [0, 0, 2.0 / @radius_z_2]
    ])
    n = t.multiply(n)
    n.toUnitVector()

  intersects: (ray) ->
    oc = ray.line.anchor.subtract(@center)
    dir = ray.line.direction.toUnitVector()
    a = ((dir.e(1) * dir.e(1)) / @radius_x_2) +
    ((dir.e(2) * dir.e(2)) / @radius_y_2) +
    ((dir.e(3) * dir.e(3)) / @radius_z_2)
    b = ((2 * oc.e(1) * dir.e(1)) / @radius_x_2) +
    ((2 * oc.e(2) * dir.e(2)) / @radius_y_2) +
    ((2 * oc.e(3) * dir.e(3)) / @radius_z_2)
    c = ((oc.e(1) * oc.e(1)) / @radius_x_2) +
    ((oc.e(2) * oc.e(2)) / @radius_y_2) +
    ((oc.e(3) * oc.e(3)) / @radius_z_2) - 1

    under_root = ((b * b) - (4.0 * a * c))
    return null if under_root < 0 or a is 0 or b is 0 or c is 0

    root = Math.sqrt(under_root)
    t1 = (-b + root) / (2 * a)
    t2 = (-b - root) / (2 * a)
    return t2  if t1 < RayConfig.intersectionDelta
    return t1  if t2 < RayConfig.intersectionDelta
    Math.min t1, t2


