# From: http://cudaopencl.blogspot.ch/2012/12/ellipsoids-finally-added-to-ray-tracing.html#

class Ellipsoid
  constructor: (@center, @radius_x, @radius_y, @radius_z, @reflectionProperties) ->
    @radius_x_2 = Math.square @radius_x
    @radius_y_2 = Math.square @radius_y
    @radius_z_2 = Math.square @radius_z

  norm: (intersectionPoint) ->
    # This is the naive way:
    # zz = intersectionPoint.subtract(@center)
    # nx = 2 * zz.e(1) / @radius_x_2
    # ny = 2 * zz.e(2) / @radius_y_2
    # nz = 2 * zz.e(3) / @radius_z_2
    # return $V([nx, ny, nz]).toUnitVector()

    # And this is the right way
    n = intersectionPoint.subtract(@center)
    t = $M([
      [2 / @radius_x_2, 0, 0],
      [0, 2 / @radius_y_2, 0],
      [0, 0, 2 / @radius_z_2]
    ])
    n = t.multiply(n)
    n.toUnitVector()

  solutions: (ray) ->
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

    Math.solveN2(a, b, c)
