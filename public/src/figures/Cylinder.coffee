class Cylinder
  constructor: (@axis_line, @fixed_x, @fixed_y, @fixed_z, @radius_x, @radius_y, @radius_z, @reflectionProperties) ->
    @radius_x_2 = Math.square(@radius_x)
    @radius_y_2 = Math.square(@radius_y)
    @radius_z_2 = Math.square(@radius_z)

  norm: (intersectionPoint) ->
    intersection = $V([((if @fixed_x then 0 else (intersectionPoint.e(1)) / @radius_x_2)),
              ((if @fixed_y then 0 else (intersectionPoint.e(2)) / @radius_y_2)),
              ((if @fixed_z then 0 else (intersectionPoint.e(3)) / @radius_z_2))])
    n = intersection.subtract(@axis_line)
    n.toUnitVector()

  solutions: (ray) ->
    oc = ray.line.anchor.subtract(@axis_line)
    dir = ray.line.direction.toUnitVector()

    a = ((if @fixed_x then 0 else ((dir.e(1) * dir.e(1)) / @radius_x_2))) +
    ((if @fixed_y then 0 else (dir.e(2) * dir.e(2) / @radius_y_2))) +
    ((if @fixed_z then 0 else dir.e(3) * dir.e(3) / @radius_z_2))

    b = ((if @fixed_x then 0 else ((2 * oc.e(1) * dir.e(1)) / @radius_x_2))) +
    ((if @fixed_y then 0 else ((2 * oc.e(2) * dir.e(2)) / @radius_y_2))) +
    ((if @fixed_z then 0 else ((2 * oc.e(3) * dir.e(3)) / @radius_z_2)))

    c = ((if @fixed_x then 0 else ((oc.e(1) * oc.e(1)) / @radius_x_2))) +
    ((if @fixed_y then 0 else ((oc.e(2) * oc.e(2)) / @radius_y_2))) +
    ((if @fixed_z then 0 else ((oc.e(3) * oc.e(3)) / @radius_z_2))) - 1

    under_root = (Math.square(b) - (4 * a * c))
    return null if under_root < 0 || a == 0 || b == 0 || c == 0

    root = Math.sqrt(under_root)
    t1 = (-b + root) / (2 * a)
    t2 = (-b - root) / (2 * a)
    return t2  if t1 < RayConfig.intersectionDelta
    return t1  if t2 < RayConfig.intersectionDelta

    # returns the smaller ti first
    if t1 <= t2
      return [t1, t2]
    return [t2, t1]

  intersection: (ray) ->
    i = this.intersects(ray)
    return null unless i

    intersectionPoint = ray.line.anchor.add(ray.line.direction.multiply(i))
    normal = this.norm(intersectionPoint)
    [i, intersectionPoint, normal]

  intersection: (ray) ->
    i = this.solutions(ray)
    return null unless i
    [t1, t2] = i
    new Intersection(ray, this, this, t1, t2, @reflectionProperties)
